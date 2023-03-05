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
    @Published var stages = [ProductionStage]()

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
                user.idUser = idCurrentUser
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
                user.idUser = idCurrentUser
                user.date = Date().timeStamp()
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
    
    var idCurrentUser = ""
    
    init() {
        print("START: UsersAdminAppViewModel")
       StageDataManager.shared.loadCollection(completion: { stages in
            if let stages = stages {
                self.stages = stages
            }
        })
        StorageManager.shared.load(type: .user, model: UserAPP.self) { card in
            if let card = card {
                self.idCurrentUser = card.id
            }
        }
        fethUsersAPP()
        
    }
    deinit {
        print("CLOSE: UsersAdminAppViewModel")
    }
    //MARK: -  изменение роли пользователя
    func changeRoleUser(to role: UserRole) {
        let role = role.role
        if let index = user.roles.firstIndex(of: role) {
            user.roles.remove(at: index)
        } else {
            user.roles.append(role)
        }
    }
    
    //MARK: -  изменение производственного этапа пользователя
    func changeStageUser(to stage: ProductionStage) {
        let name = stage.name
        if let index = user.stages.firstIndex(of: name) {
            user.stages.remove(at: index)
        } else {
            user.stages.append(name)
        }
    }
    
    
    
    //MARK: -  получение актуального массива пользователей из сети
    private func fethUsersAPP() {
        UserDataManager.shared.loadCollection { usersAPP in
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
        UserDataManager.shared.createCard (to: user) { _ in
            if let index = self.users.firstIndex(where: {$0.id == self.user.id}) {
                self.users[index] = self.user
            }
            self.showEditUser.toggle()
        }
    }
    
    //MARK: - добавляем нового пользователя
    private func addUser() {
        UserDataManager.shared.createCard(to: user) { _ in
            self.users.append(self.user)
            self.showAddUser.toggle()
        }
    }
}
