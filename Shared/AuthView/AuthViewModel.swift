//
//  AuthViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation

enum AuthViews {
    case auth, edit, repair, version
}

class AuthViewModel: ObservableObject {
    
    // переменные полей пользователя для входа по паролю
    @Published var email = ""
    @Published var passwordEnter = ""
    
    // поля пользователя для регистрации
    @Published var name = ""
    @Published var surname = ""
    @Published var phone = ""
    @Published var image = Data()
    
    
    
    
    // отвечает за показ активного окна
    @Published var showView: AuthViews = .auth
    
    // признак проверки входа по паролю
    @Published var isAuth = false {
        didSet {
            checkLogIn()
        }
    }
    
    // признак отправки сообщения на восстановление
    @Published var isSendRecovery = false {
        didSet {
            sendRecoveryPassword()
        }
    }
    // признак окончания загрузки пользователя
    @Published var isFinishLoadUser = false

    // признак корректной версии программы
    @Published var isVersion = false
    
    // отработка экрана ошибки
    @Published var errorText = ""
    @Published var errorOccured = false

    
    init() {
        print("START: AuthViewModel")
        checkVersion()
        checkFirstKey()
    }
    deinit {
        print("CLOSE: AuthViewModel")
    }
    private func checkFirstKey() {
        let key = StorageManager.shared.checkKey(type: TypeKey.app)
        if !key {
            showView = .auth
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
                    self.isFinishLoadUser = false
                    if let name = AuthUserManager.shared.userSession?.uid, let email = AuthUserManager.shared.userSession?.email {
                        NetworkManager.shared.loadUser(name: name) { result in
                            switch result {
                            case .success(let user):
                                let userCurrent = StorageManager.shared.getUserToUserCurrent(user: user)
                                self.isFinishLoadUser = true
                                StorageManager.shared.saveUser(at: userCurrent)
                                StorageManager.shared.settingKey(to: TypeKey.app, key: true)
                            case .failure(_):
                                print("надо сформировать новый профиль")
                                self.email = email
                                self.showView = .edit
                            }
                        }
                    }
                }
            }
        }
    }
    
//    // загрузка фото пользователя
//    private func loadUserImage(user: User, completion: @escaping () -> Void) {
//        NetworkManager.shared.loadFile(type: .user_image, name: user.image) { result in
//            switch result {
//            case .success(let image):
//                self.userCurrent?.image = image
//                completion()
//            case .failure(_):
//                print("ERROR: Load User Image")
//                completion()
//            }
//        }
//    }
//
//    // загрузка профиля пользователя
//    private func loadUserData(user: User, completion: @escaping () -> Void) {
//        NetworkManager.shared.loadFile(type: .user_data, name: user.profile) { result in
//            switch result {
//            case .success(let data):
//                do {
//                    let userData = try JSONDecoder().decode(UserData.self, from: data)
//                    self.userCurrent?.profile = userData
//                    completion()
//                } catch {
//                    print("ERROR: Decode User Profile")
//                    completion()
//                }
//            case .failure(_):
//                print("ERROR: Load User Profile")
//                completion()
//            }
//        }
//    }
}

extension AuthViewModel {
    // проверка версии программы
    private func checkVersion() {
        NetworkManager.shared.fetchVersion { result in
            switch result {
            case .success(let ver):
                if ver == version {
                    self.isVersion = true
                } else {
                    self.errorText = NotificationMessage.version.text
                    self.errorOccured = true
                }
            case .failure(_):
                print("ERROR: fetchVersion")
            }
        }
    }
    
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
}
