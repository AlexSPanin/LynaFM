//
//  UsersAdminAppViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import Foundation

enum TapButtonUsers: Codable {
    case no, addUser, editUser
}

class UsersAdminAppViewModel: ObservableObject {
    @Published var label = "Справочник пользователей"
    
    @Published var name = ""
    @Published var surname = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var password = ""
    var user: User?
    @Published var userData = UserData()
    
    @Published var users: [User] = []
    @Published var press: TapButtonUsers = .no {
        didSet {
            switch press {
            case .no:
                do {}
            case .addUser:
                addUser()
            case .editUser:
                editUser()
            }
        }
    }
    @Published var showAddUser = false {
        didSet {
            if showAddUser {
                label = "Добавить нового пользователя"
                createUserData()
            } else {
                clearData()
            }
        }
    }
    
    @Published var showEditUser = false {
        didSet {
            if showEditUser {
                label = "Изменить данные пользователя"
                prepairUserData()
            } else {
                clearData()
            }
        }
    }
    
    @Published var isActiveEdit = false {
        didSet {
            print("isActiveEdit \(isActiveEdit)")
        }
    }
    // отработка экрана ошибки
    @Published var errorText = ""
    @Published var errorOccured = false
    init() {
        print("START: UsersAdminAppViewModel")
        StorageManager.shared.load(type: .users, model: [UserAPP].self) { result in
            switch result {
            case .success(let usersAPP):
                self.users = StorageManager.shared.convertToUsers(usersAPP: usersAPP)
            case .failure(_):
                print("Ошибка загрузки списка пользователей из памяти")
                NetworkManager.shared.fetchFullCollection(to: .user, model: User.self) { result in
                    switch result {
                    case .success(let users):
                        let usersAPP = StorageManager.shared.convertToUsersApp(users: users)
                        let collection = usersAPP as Any
                        StorageManager.shared.save(type: .users, model: [UserAPP].self, collection: collection)
                        self.users = users
                    case .failure(_):
                        print("Ошибка загрузки списка пользователей из сети")
                    }
                }
            }
        }
    }
    deinit {
        print("CLOSE: UsersAdminAppViewModel")
    }
    
    
    
    //MARK: - подготовка выбранного профиля
    private func prepairUserData() {
        if let user = user {
            print("Профиль для редактирования \(user.id ?? "") profile \(user.profile)")
            name = user.name
            surname = user.surname
            phone = user.phone
            let profile = user.profile
            if profile.isEmpty {
                createUserData()
                isActiveEdit = true
            } else {
                NetworkManager.shared.loadFile(type: .user, name: profile, model: UserData.self) { result in
                    switch result {
                    case .success(let userData):
                        self.userData = userData
                        self.isActiveEdit = true
                    case .failure(_):
                        print("Ошибка загрузки из сети профиля пользователя")
                    }
                }
            }
        }
    }
    
    
    
    //MARK: - добавляем карточку пользователя
    private func editUser() {
        print("Сохранение изменений профиля")
        print(userData)
        user?.name = name
        user?.surname = surname
        user?.phone = phone
        
        if var user = user, let index = users.firstIndex(where: {$0.id == user.id}) {
            NetworkManager.shared.upLoadFile(to: user.profile.isEmpty ? nil : user.profile, type: .user, model: UserData.self, collection: userData) { [self] file in
                user.profile = file
                NetworkManager.shared.upLoadUser(to: user.id, user: user)
                
                users[index].name = name
                users[index].surname = surname
                users[index].phone = phone
                users[index].profile = file
                let usersAPP = StorageManager.shared.convertToUsersApp(users: users)
                let collection = usersAPP as Any
                StorageManager.shared.save(type: .users, model: [UserAPP].self, collection: collection)
                showEditUser.toggle()
            }
        } 
    }
    
    //MARK: - добавляем нового пользователя
    private func addUser() {
        AuthUserManager.shared.registrationPassword(email: email, password: password) { text, error in
            if error {
                self.errorText = text
                self.errorOccured = error
                self.password = ""
                self.email = ""
                return
            } else {
                
                var user = User(id: text,
                                email: self.email,
                                phone: self.phone,
                                name: self.name,
                                surname: self.surname)
                NetworkManager.shared.upLoadFile(type: .user, model: UserData.self, collection: self.userData) { file in
                    user.profile = file
                    NetworkManager.shared.upLoadUser(to: user.id, user: user)
                    self.users.append(user)
                    let usersAPP = StorageManager.shared.convertToUsersApp(users: self.users)
                    let collection = usersAPP as Any
                    StorageManager.shared.save(type: .users, model: [UserAPP].self, collection: collection)
                    self.showAddUser.toggle()
                }
            }
        }
        
    }
    
    //MARK: -  заполняем список не активированных ролей
    private func createUserData() {
        print("Подготовка пустой UsedData")
        UserRole.allCases.forEach { role in
            userData.roles[role] = false
        }
    }
    
    //MARK: - отчистка данных
    private func clearData() {
        label = "Справочник пользователей"
        name = ""
        surname = ""
        phone = ""
        email = ""
        password = ""
        user = nil
        userData = UserData()
    }
    
}
