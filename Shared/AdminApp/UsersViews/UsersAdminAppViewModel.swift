//
//  UsersAdminAppViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import Foundation

class UsersAdminAppViewModel: ObservableObject {
    @Published var label = "Справочник пользователей"
    @Published var users = [UserAPP]()
    @Published var user = UserAPP()
    @Published var password = ""
    

    @Published var isAddUser = false {
        didSet {
            if isAddUser {
                addUser()
            }
        }
    }
    
    @Published var isEditUser = false {
        didSet {
            if isEditUser {
                editUser()
            }
        }
    }
    
    @Published var showAddUser = false {
        didSet {
            if showAddUser {
                label = "Добавить нового пользователя"
                user = UserAPP()
                password = ""
            } else {
                label = "Справочник пользователей"
                isAddUser = false
                fethUsersAPP()
            }
        }
    }
    
    @Published var showEditUser = false {
        didSet {
            if showEditUser {
                label = "Изменить данные пользователя"
            } else {
                label = "Справочник пользователей"
                isEditUser = false
                fethUsersAPP()
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
        UserDataManager.shared.loadUsers { usersAPP in
            if let usersAPP = usersAPP {
                let collection = usersAPP as Any
                StorageManager.shared.save(type: .users, model: [UserAPP].self, collection: collection)
                self.users = usersAPP
            } else {
                print("Ошибка загрузки списка пользователей из сети")
            }
        }
    }
    
    
    //MARK: - добавляем карточку пользователя
    private func editUser() {
        print("Сохранение изменений профиля")
        UserDataManager.shared.updateUser(to: user) { status in
            if status {
                let currentID = AuthUserManager.shared.currentUserID()
                print("ID авторизованного пользователя \(currentID)")
   //             print("ID редактируемого пользователя \(self.user.id)")
                if let userID = self.user.id, currentID == userID {
                    print("Сохранение изменений авторизированного профиля")
                    let collection = self.user as Any
                    StorageManager.shared.save(type: .user, model: UserAPP.self, collection: collection)
                }
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
                    self.showAddUser.toggle()
                }
            }
        }
    }
}
