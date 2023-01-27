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

class AuthViewModel: ObservableObject {
    
    // переменные полей пользователя для входа по паролю
    @Published var email = ""
    @Published var passwordEnter = ""
    
    // поля пользователя для регистрации
    @Published var name = ""
    @Published var surname = ""
    @Published var phone = ""
    @Published var imageData = Data()
    var image: String?

    // отвечает за показ активного окна
    @Published var showView: AuthViews = .error
    
    @Published var showAvatarPhotoView = false
    
    // признак запуска методов
    @Published var isAuth = false {
        didSet {
            checkLogIn()
        }
    }
    
    @Published var isEdit = false {
        didSet {
            saveProfile()
        }
    }
    
    @Published var isExit = false {
        didSet {
            exitProfile()
        }
    }
    
    // признак отправки сообщения на восстановление
    @Published var isSendRecovery = false {
        didSet {
            sendRecoveryPassword()
        }
    }
    // признак окончания работы раздела авторизации
    @Published var isFinish = false
    
    // признак корректной версии программы
    @Published var isVersion = false
    
    // отработка экрана ошибки
    @Published var errorText = ""
    @Published var errorOccured = false

    
    init() {
        print("START: AuthViewModel")
      
        checkCurrentUser()
    }
    deinit {
        print("CLOSE: AuthViewModel")
    }
    //MARK: - загрузка фото пользователя
    private func loadImage(to file: String) {
        FileAppManager.shared.loadFileData(to: file, type: .temp) { result in
            switch result {
            case .success(let data):
                self.imageData = data
            case .failure(_):
                NetworkManager.shared.loadFile(type: .user, name: file) { result in
                    switch result {
                    case .success(let data):
                        FileAppManager.shared.saveFileData(to: file, type: .temp, data: data)
                        self.imageData = data
                    case .failure(_):
                        print("ERROR: load Image")
                    }
                }
            }
        }
    }
    
    //MARK: - проверка наличия коллекции пользователей на устройстве
    private func checkCurrentUser() {
        AuthUserManager.shared.updateUserSession()
        if let id = AuthUserManager.shared.userSession?.uid {
            StorageManager.shared.load(type: .users, model: [User].self){ result in
                switch result {
                case .success(let users):
                    if let user = users.first(where: {$0.id == id }) {
                        self.name = user.name
                        self.surname = user.surname
                        self.phone = user.phone
                        self.loadImage(to: user.image)
                        self.image = user.image
                        StorageManager.shared.save(type: .user, model: User.self, collection: user)
                        self.showView = .starting
                    } else {
                        self.errorText = "Ошибка: нет Карточки.\nОбратитесь к администратору."
                        self.errorOccured.toggle()
                        self.exitProfile()
                    }
                case .failure(_):
                    // если в памяти нет коллекции отправляем в окно аторизации
                    self.showView = .auth
                }
            }
        } else {
            showView = .error
        }
    }
    
    
    
    // сохранить профиль
    private func saveProfile() {
        if name.isEmpty || surname.isEmpty || phone.isEmpty {
            errorText = "Все поля должны\nбыть заполнены"
            errorOccured.toggle()
            return
        } else {
            AuthUserManager.shared.updateUserSession()
            if let id = AuthUserManager.shared.userSession?.uid, let email = AuthUserManager.shared.userSession?.email {
                var user = User(email: email, phone: self.phone, name: self.name, surname: self.surname)
                NetworkManager.shared.upLoadFile(to: image, type: .user, data: self.imageData) { file in
                    user.id = id
                    user.image = file
                    NetworkManager.shared.upLoadUser(user: user) {}
                    StorageManager.shared.save(type: .user, model: User.self, collection: user)
                    FileAppManager.shared.saveFileData(to: file, type: .temp, data: self.imageData)
                    self.isFinish = true
                }
                user.id = id
            }
        }
    }

    // проверка входа по паролю
    private func checkLogIn() {
        print("LoginUserViewModel: Начало входа по паролю")
        if email.isEmpty || passwordEnter.isEmpty {
            errorText = "Все поля должны\nбыть заполнены"
            errorOccured.toggle()
            return
        } else {
           
            AuthUserManager.shared.login(email: email, password: passwordEnter) { text, error in
                if error {
                    self.errorText = text
                    self.errorOccured = error
                    self.passwordEnter = ""
                    self.email = ""
                    return
                } else {
                    if let name = AuthUserManager.shared.userSession?.uid {
                        NetworkManager.shared.fetchElementCollection(to: .user, doc: name, model: User.self) { result in
                            switch result {
                            case .success(let user):
                                StorageManager.shared.save(type: .user, model: User.self, collection: user)
                                self.isFinish = true
                            case .failure(_):
                                print("надо сформировать новый профиль")
                                self.showView = .edit
                            }
                        }
                    }
                }
            }
        }
    }
}

extension AuthViewModel {

    // метод отправки сообщения на восстановление на указанную почту
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
        showView = .auth
        email = ""
        passwordEnter = ""
        name = ""
        surname = ""
        phone = ""
        imageData = Data()
        image = nil
        StorageManager.shared.settingKey(to: .system, key: false)
        showView = .exit
    }
}
