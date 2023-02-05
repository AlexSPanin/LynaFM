//
//  AuthViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation

enum AuthViews {
    case auth, edit, repair, error, starting, create, exit
}

final class AuthViewModel: ObservableObject {
    // сообщение для окон ошибки
    @Published var label = ""
    
    @Published var userAPP = UserAPP()
    // переменные полей пользователя для входа по паролю
 //   @Published var email = ""
    @Published var passwordEnter = ""

    // отвечает за показ активного окна
    @Published var showView: AuthViews = .error {
        didSet {
            if showView == .starting {
                StorageManager.shared.load(type: .user, model: UserAPP.self) { result in
                    switch result {
                    case .success(let user):
                        self.userAPP = user
                    case .failure(_):
                        print("Ошибка загрузки авторизованного пользователя из памяти")
                    }
                }
            }
        }
    }
    // признак показа окна работы с аватаром пользователя
    @Published var showAvatarPhotoView = false
    
    // авторизация пользователя по логину и паролю
    @Published var isAuth = false {
        didSet {
            checkLogIn()
        }
    }
    // редактирование профиля пользователя
    @Published var isEdit = false {
        didSet {
            saveProfile() { [self] status in
                if status {
                    showView = .starting
                } else {
                    errorText = "Ошибка редактирования профиля."
                    errorOccured = true
                }
                
            }
            
        }
    }
    // создание новой карточки профиля пользователя
    @Published var isCreate = false {
        didSet {
            createProfile()
            showView = .starting
        }
    }
    // выход из текущего профиля
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
    
    // окончание работы экранов авторизации
    @Published var isFinish = false {
        didSet {
            if isFinish {
                saveProfile() {_ in }
            }
        }
    }
    
    // признак корректной версии программы
    @Published var isVersion = false
    
    // отработка экрана ошибки
    @Published var errorText = ""
    @Published var errorOccured = false
    
    var systemAPP: SystemApp?
    var checkList: [NetworkCollection: CheckLine]?
    // признак окончания загрузки базы данных
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
        userAPP.id = AuthUserManager.shared.currentUserID()
        if let id = userAPP.id, !id.isEmpty {
            print("Пользователь Авторизован отправляем на загрузку базы данных \(id)")
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
    
    //MARK: - проверка пользователя
    private func checkCurrentUser() {
        print("Начало проверки пользователя")
        StorageManager.shared.load(type: .user, model: UserAPP.self){ result in
            switch result {
            case .success(let user):
                print("Карточка пользователя в памяти")
                self.userAPP = user
                self.showView = .starting
            case .failure(_):
                print("Если карточки нет в памяти то это первый запуск и авторизация")
                self.showView = .auth
            }
        }
    }
 
    //MARK: - сохранить профиль после редактирования
    private func saveProfile(completion: @escaping(Bool) -> Void) {
        if userAPP.name.isEmpty || userAPP.surname.isEmpty || userAPP.phone.isEmpty {
            completion(false)
        } else {
            let email = AuthUserManager.shared.currentUserEmail()
            userAPP.email = email
            UserDataManager.shared.updateUser(to: userAPP) { status in
                if status {
                    let collection = self.userAPP as Any
                    StorageManager.shared.save(type: .user, model: UserAPP.self, collection: collection)
                }
                completion(status)
            }
        }
    }
    
    //MARK: - сохранить новый профиль
    private func createProfile() {
        if userAPP.name.isEmpty || userAPP.surname.isEmpty || userAPP.phone.isEmpty {
            errorText = "Все поля должны\nбыть заполнены"
            errorOccured.toggle()
            return
        } else {
            let email = AuthUserManager.shared.currentUserEmail()
            userAPP.email = email
            userAPP.profile = UserDataManager.shared.createUserData()
            UserDataManager.shared.createNewUser(to: userAPP) { status in
                let collection = self.userAPP as Any
                StorageManager.shared.save(type: .user, model: UserAPP.self, collection: collection)
            }
        }
    }


    //MARK: - проверка входа по паролю
    private func checkLogIn() {
        print("LoginUserViewModel: Начало входа по паролю")
        if userAPP.email.isEmpty || passwordEnter.isEmpty {
            errorText = "Все поля должны\nбыть заполнены"
            errorOccured.toggle()
            return
        } else {
           
            AuthUserManager.shared.login(email: userAPP.email, password: passwordEnter) { text, error in
                if error {
                    self.errorText = text
                    self.errorOccured = error
                    self.passwordEnter = ""
                    self.userAPP.email = ""
                    return
                } else {
                    print("Загрузка из сети если в памяти нет карточки пользователя")
                    UserDataManager.shared.loadUser(to: self.userAPP.id) { result in
                        switch result {
                        case .success(let user):
                            self.userAPP = user
                            let collection = user as Any
                            StorageManager.shared.save(type: .user, model: UserAPP.self, collection: collection)
                            self.showView = .starting
                        case .failure(_):
                            print("Если карточки нет - надо сформировать новый профиль")
                            self.showView = .create
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
  //      print("Проверка Чек листа")
        if let checkList = checkList {
            finishLoadDB = !checkList.contains(where: {$0.value.isLoading})
  //          print("finishLoadDB \(finishLoadDB)")
        }
    }

    //MARK: - метод отправки сообщения на восстановление на указанную почту
    private func sendRecoveryPassword() {
        if userAPP.email.isEmpty {
            errorText = "Укажите электронную почту"
            errorOccured.toggle()
            return
        }
        AuthUserManager.shared.sendLinkForPasswordReset(with: userAPP.email) { errorText, errorOccured in
            if errorOccured {
                self.errorText = errorText
                self.errorOccured = errorOccured
                self.userAPP.email = ""
            } else {
                self.errorText = errorText
                self.errorOccured = !errorOccured
            }
        }
    }
    //MARK: -  очищаем профиль, скидываем системные данные и отправляем на окно закрытия программы
    private func exitProfile() {
        passwordEnter = ""
        userAPP = UserAPP()
        StorageManager.shared.remove(type: .user)
        checkAutchUser()
        
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
        print("проверяем базу коллекции Пользователей")
        if let checkList = checkList, let isLoading = checkList[.user]?.isLoading, isLoading {
            print("Начало загрузки из сети Users Collection Base")
            UserDataManager.shared.loadUsers { result in
                switch result {
                case .success(let usersAPP):
                    let collection = usersAPP as Any
                    StorageManager.shared.save(type: .users, model: [UserAPP].self, collection: collection)
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
