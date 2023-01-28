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
    @Published var label = ""
    
    
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
    @Published var isStart = false {
        didSet {
            if isStart {
            checkAutchUser()
            }
        }
    }
    @Published var isFinish = false
    
    // признак корректной версии программы
    @Published var isVersion = false
    
    // отработка экрана ошибки
    @Published var errorText = ""
    @Published var errorOccured = false
    
    var userID = ""
    var systemAPP: SystemApp?
    var checkList: [NetworkCollection: CheckLine]?
    var finishLoadDB = false {
        didSet {
            if finishLoadDB {
            checkCurrentUser()
            }
        }
    }
    

    
    init() {
        print("START: AuthViewModel")
    }
    deinit {
        print("CLOSE: AuthViewModel")
    }
    
    //MARK: - проверка и загрузка баз данных
    private func checkAutchUser() {
        userID = AuthUserManager.shared.currentUserID()
        print("ID Пользователя \(userID)")
        if !userID.isEmpty {
            print("Пользователь Авторизован отправляем на загрузку базы данных")
            loadDataBase()
        } else {
            print("пытаемся авторизоваться")
            showView = .auth
        }
    }
    
        //MARK: - загрузка коллекций баз данных
        private func loadDataBase() {
            print("Начало загрузки баз данных")
            let myGroup = DispatchGroup()
            loadSystemAPP()
            
            myGroup.enter()
            checkUsersCollection {
                myGroup.leave()
            }
    
            myGroup.notify(queue: .main) {
                self.updateCheckList()
            }
        }
    
    //MARK: - проверка наличия коллекции пользователей на устройстве
    private func checkCurrentUser() {
        print("Начало проверки пользователя")
        StorageManager.shared.load(type: .user, model: UserAPP.self){ result in
            switch result {
            case .success(let user):
                print("Карточка пользователя в памяти")
                self.name = user.name
                self.surname = user.surname
                self.phone = user.phone
                self.loadImage(to: user.image)
                self.image = user.image
                self.showView = .starting
            case .failure(_):
                print("Если карточки нет в памяти то это первый запуск и авторизация")
                self.showView = .auth
            }
        }
    }
 
    // сохранить профиль
    private func saveProfile() {
        if name.isEmpty || surname.isEmpty || phone.isEmpty {
            errorText = "Все поля должны\nбыть заполнены"
            errorOccured.toggle()
            return
        } else {
            let email = AuthUserManager.shared.currentUserEmail()
            let id = userID
            var user = User(email: email, phone: self.phone, name: self.name, surname: self.surname)
            NetworkManager.shared.upLoadFile(to: image, type: .user, data: self.imageData) { file in
                user.id = id
                user.image = file
                let userAPP = StorageManager.shared.convertToUserAPP(user: user)
                NetworkManager.shared.upLoadUser(user: user) {}
                StorageManager.shared.save(type: .user, model: UserAPP.self, collection: userAPP)
                FileAppManager.shared.saveFileData(to: file, type: .temp, data: self.imageData)
                self.isFinish = true
            }
        }
    }

    //MARK: - проверка входа по паролю
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
                        print("Загрузка из сети если в памяти нет карточки пользователя")
                    NetworkManager.shared.fetchElementCollection(to: .user, doc: self.userID, model: User.self) { result in
                            switch result {
                            case .success(let user):
                                self.name = user.name
                                self.surname = user.surname
                                self.phone = user.phone
                                self.loadImage(to: user.image)
                                self.image = user.image
                                let userAPP = StorageManager.shared.convertToUserAPP(user: user)
                                StorageManager.shared.save(type: .user, model: UserAPP.self, collection: userAPP)
                                self.showView = .starting
                            case .failure(_):
                                print("Если карточки нет - надо сформировать новый профиль")
                                self.showView = .edit
                            }
                        }
                }
            }
        }
    }
}

extension AuthViewModel {
    //MARK: - проверка чек листа
    private func updateCheckList() {
        print("Проверка Чек листа")
        if let checkList = checkList {
            finishLoadDB = !checkList.contains(where: {$0.value.isLoading})
            print("finishLoadDB \(finishLoadDB)")
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
        showView = .auth
        email = ""
        passwordEnter = ""
        name = ""
        surname = ""
        phone = ""
        imageData = Data()
        image = nil
        StorageManager.shared.remove(type: .system)
        StorageManager.shared.remove(type: .user)
        StorageManager.shared.remove(type: .users)
        AuthUserManager.shared.exitingUser { _, _ in
            do {}
        }
        label = "Теперь Вы можете закрыть приложение."
        showView = .exit
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
    //MARK: - загрузка системного файла
    private func loadSystemAPP() {
        StorageManager.shared.load(type: .system, model: SystemApp.self) { result in
            switch result {
            case .success(let system):
                self.systemAPP = system
            case .failure(_):
                self.label = "Ошибка: сбой загрузки системного файла.\nОбратитесь к администратору."
                self.showView = .error
            }
        }
    }
    
    //MARK: - проверка и обновление коллекции пользователей
    private func checkUsersCollection(completion: @escaping() -> Void) {
        print("проверяем базу коллекции")
        if let checkList = checkList, let isLoading = checkList[.user]?.isLoading, isLoading {
            print("Начало загрузки из сети Users Collection Base")
            NetworkManager.shared.fetchFullCollection(to: .user, model: User.self) { result in
                switch result {
                case .success(let collection):
                    print("Коллекция из сети загружена Users Collection")
                    let usersAPP = StorageManager.shared.convertToUsersApp(users: collection)
                    StorageManager.shared.save(type: .users, model: [UserAPP].self, collection: usersAPP)
                    self.checkList?[.user] = CheckLine(app: self.systemAPP?.user, server: self.systemAPP?.user)
                    completion()
                case .failure(_):
                    self.label = "Ошибка: сбой обнавления коллекции.\nОбратитесь к администратору."
                    self.showView = .error
                }
            }
        } else {
            completion()
        }
    }
}
