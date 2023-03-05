//
//  AuthViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation

enum AuthViews {
    case auth, edit, repair, error, starting, exit
}

final class AuthViewModel: ObservableObject {
    // сообщение для окон ошибки
    @Published var title = "AuthViewModel"
    
    
    @Published var currentUser: UserAPP?
    var cards = [UserAPP]()
    var systemAPP: SystemApp?
    
    // переменные полей пользователя для входа по паролю
    @Published var email = ""
    @Published var password = ""
    @Published var photo: Data?
    
    //MARK: - признаки показа окон
    @Published var showProgressView = false
    @Published var showView: AuthViews = .error {
        didSet {
            if showView == .starting {
                loadPhoto()
            }
        }
    }
    @Published var showFolder = false
    
    // признак начала проверки пользователя
    @Published var isStart = false {
        didSet {
            showProgressView.toggle()
            fethNetwork { status in
                if status {
                    self.showProgressView.toggle()
                    self.checkAutchUser()
                } else {
                    self.showProgressView.toggle()
                    self.showView = .auth
                }
            }
        }
    }
    // выход из текущего профиля
    @Published var isExit = false {
        didSet { exitProfile() }
    }
    // авторизация пользователя по логину и паролю
    @Published var isAuth = false {
        didSet { checkLogIn() }
    }
    // признак отправки сообщения на восстановление
    @Published var isSendRecovery = false {
        didSet { sendRecoveryPassword() }
    }
    
    // редактирование профиля пользователя
    @Published var isEdit = false {
        didSet {
            updateProfile(image: photo) { [self] status in
                if status {
                    showView = .starting
                } else {
                    errorText = "Ошибка редактирования профиля."
                    errorOccured = true
                }
            }
            
        }
    }
    
    @Published var isChange = false

    // отработка экрана ошибки
    @Published var errorText = ""
    @Published var errorOccured = false

    init() {
        print("START: AuthViewModel")
    }
    deinit {
        print("CLOSE: AuthViewModel")
    }
    
    //MARK: -  получение актуального массива  из сети
    private func fethNetwork(completion: @escaping(Bool) -> Void) {
        if AuthUserManager.shared.currentUserEmail() != nil {
            UserDataManager.shared.loadCollection { cards in
                if let cards = cards {
                    print(cards)
                    self.cards = cards
                    completion(true)
                }
            }
        }
        completion(false)
    }
    
    //MARK: - проверка и загрузка баз данных
    private func checkAutchUser() {
        if let email = AuthUserManager.shared.currentUserEmail() {
            print(email)
            if let currentUser = cards.first(where: { $0.email == email }) {
                self.currentUser = currentUser
                let collection = currentUser as Any
                StorageManager.shared.save(type: .user, model: UserAPP.self, collection: collection)
                self.showView = .starting
            } else {
                showView = .error
            }
        } else {
            showView = .auth
        }
    }
    
    private func loadPhoto() {
        if let currentUser = currentUser {
            UserDataManager.shared.loadFile(to: currentUser.image) { data in
                self.photo = data
            }
        }
    }

 
    //MARK: - сохранить профиль после редактирования
    private func updateProfile(image: Data? = nil, completion: @escaping(Bool) -> Void) {
        if isChange, let card = currentUser {
            if let image = image {
                let file = card.image.isEmpty ? UUID().uuidString + ".png" : card.image
                currentUser?.image = file
                FileAppManager.shared.saveFileData(to: file, type: .assets, data: image)
            }
            UserDataManager.shared.createCard(to: card) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }
}

extension AuthViewModel {
    //MARK: - проверка входа по паролю
    private func checkLogIn() {
        if  email.isEmpty || password.isEmpty {
            errorText = "Все поля должны\nбыть заполнены"
            errorOccured.toggle()
            return
        } else {
            AuthUserManager.shared.login(email: email, password: password) { text, error in
                if error {
                    self.errorText = text
                    self.errorOccured = error
                    self.password = ""
                    self.email = ""
                    return
                } else {
                    self.checkAutchUser()
                }
            }
        }
    }
    //MARK: - метод отправки сообщения на восстановление на указанную почту
    private func sendRecoveryPassword() {
        if email.isEmpty {
            errorText = "Укажите электронную почту"
            errorOccured.toggle()
            return
        }
        AuthUserManager.shared.sendLinkForPasswordReset(with: email) { errorText, errorOccured in
            if errorOccured {
                self.errorText = errorText
                self.errorOccured = errorOccured
                self.email = ""
            } else {
                self.errorText = errorText
                self.errorOccured = !errorOccured
            }
        }
    }
    //MARK: -  очищаем профиль, скидываем системные данные и отправляем на окно закрытия программы
    private func exitProfile() {
        AuthUserManager.shared.exitingUser { _, _ in
        }
        email = ""
        password = ""
        currentUser = nil
        checkAutchUser()
    }
}
