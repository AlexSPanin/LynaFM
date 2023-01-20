//
//  AuthViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation

enum AuthViews {
    case auth, edit, repair, version, starting
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
    var imageFile: String?
    
    
    
    
    // отвечает за показ активного окна
    @Published var showView: AuthViews = .starting
    
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
        checkVersion()
        
    }
    deinit {
        print("CLOSE: AuthViewModel")
    }
    private func checkFirstKey() {
        let key = StorageManager.shared.checkKey(type: TypeKey.app)
        if !key {
            showView = .auth
        } else {
            StorageManager.shared.fetchUserCurrent { result in
                switch result {
                case .success(let current):
                    self.name = current.name
                    self.surname = current.surname
                    self.phone = current.phone
                    self.imageFile = current.image
                case .failure(_):
                    self.errorText = "Ошибка загрузки профиля.\nАвторизируйтесь повторно."
                    self.errorOccured.toggle()
                    self.exitProfile()
                }
            }
            if let imageFile = imageFile {
                AuthUserManager.shared.updateUserSession()
                NetworkManager.shared.loadFile(type: .user_image, name: imageFile) { result in
                    switch result {
                    case .success(let data):
                        self.image = data
                    case .failure(_):
                        print("ERROR: load Image")
                    }
                }
            }
        }
    }
    
    // выйти из профиля
    private func exitProfile() {
        showView = .auth
        email = ""
        passwordEnter = ""
        name = ""
        surname = ""
        phone = ""
        image = Data()
        imageFile = ""
        let current = UserCurrent()
        StorageManager.shared.saveUser(at: current)
        StorageManager.shared.settingKey(to: TypeKey.app, key: false)
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
                var user = User(email: email, phone: phone, name: name, surname: surname)
                NetworkManager.shared.upLoadFile(to: self.imageFile, type: .user_image, data: image) { file in
                    user.id = id
                    user.image = file
                    let current = StorageManager.shared.getUserToUserCurrent(user: user)
                    NetworkManager.shared.upLoadUser(user: user) {}
                    StorageManager.shared.saveUser(at: current)
                    StorageManager.shared.settingKey(to: TypeKey.app, key: true)
                    self.isFinish = true
                }
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
                        NetworkManager.shared.loadUser(name: name) { result in
                            switch result {
                            case .success(let user):
                                let userCurrent = StorageManager.shared.getUserToUserCurrent(user: user)
                                StorageManager.shared.saveUser(at: userCurrent)
                                StorageManager.shared.settingKey(to: TypeKey.app, key: true)
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
                    self.checkFirstKey()
                } else {
                    self.showView = .version
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
