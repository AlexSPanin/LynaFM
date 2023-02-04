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
    @Published var users = [UserAPP]()
    @Published var user = UserAPP() {
        didSet {
            print(user.id ?? "")
            print(user.name)
            print(user.surname)
        }
    }
    
    @Published var password = ""
    @Published var index = 0
    
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
                user = UserAPP()
                user.profile = UserDataManager.shared.createUserData()
                password = ""
            } else {
                label = "Справочник пользователей"
            }
        }
    }
    
    @Published var showEditUser = false {
        didSet {
            if showEditUser {
                label = "Изменить данные пользователя"
            } else {
                label = "Справочник пользователей"
            }
        }
    }
    
    // отработка экрана ошибки
    @Published var errorText = ""
    @Published var errorOccured = false
    
    init() {
        print("START: UsersAdminAppViewModel")
        fethUsersAPP()
        
    }
    deinit {
        print("CLOSE: UsersAdminAppViewModel")
    }
    
    //MARK: -  получение актуального массива пользователей из сети
    private func fethUsersAPP() {
        UserDataManager.shared.loadUsers { result in
            switch result {
            case .success(let usersAPP):
                let collection = usersAPP as Any
                StorageManager.shared.save(type: .users, model: [UserAPP].self, collection: collection)
                self.users = usersAPP
            case .failure(_):
                print("Ошибка загрузки списка пользователей из сети")
            }
        }
    }
    
    
    //MARK: - добавляем карточку пользователя
    private func editUser() {
        print("Сохранение изменений профиля")
        UserDataManager.shared.updateUser(to: user) { status in
            if status {
                self.fethUsersAPP()
                self.showEditUser.toggle()
            }
        }
    }
    
    //MARK: - добавляем нового пользователя
    private func addUser() {
       
        AuthUserManager.shared.registrationPassword(email: user.email, password: password) { text, error in
            if error {
                self.errorText = text
                self.errorOccured = error
                self.password = ""
                self.user.email = ""
                return
            } else {
                self.user.id = text
                UserDataManager.shared.createNewUser(to: self.user) { status in
                    self.fethUsersAPP()
                    self.showAddUser.toggle()
                    
                }
            }
        }
    }
}
