//
//  UserDataManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 04.02.2023.
//
//MARK: - методы для работы с профилем пользователя
import Foundation
import SwiftUI

class UserDataManager {
    static let shared = UserDataManager()
    private init() {}
    //MARK: - загрузка всех карточк пользователей
    func loadUsers(completion: @escaping([UserAPP]?) -> Void) {
        print("Загрузка карточек пользователей")
        let myGroup = DispatchGroup()
        NetworkManager.shared.fetchCollection(to: .user, model: User.self) { users in
            if let users = users {
                print("Коллекция из сети загружена Users Collection")
                var usersAPP = [UserAPP]()
                users.forEach { user in
                    myGroup.enter()
                    self.loadUser(to: user.id) { userAPP in
                        if let userAPP = userAPP {
                            usersAPP.append(userAPP)
                            myGroup.leave()
                        } else {
                            print("Ошибка загрузки Пользователя \(user.name) \(user.surname)")
                            myGroup.leave()
                        }
                    }
                }
                myGroup.notify(queue: .main) {
                    completion(usersAPP)
                }
            } else {
                print("Ошибка: сбой обнавления коллекции.\nОбратитесь к администратору.")
                completion(nil)
            }
        }
    }
    
    //MARK: - загрузка карточки пользователя
    func loadUser(to id: String?, completion: @escaping(UserAPP?) -> Void) {
        if let id = id {
            print("Загрузка карточки пользователя \(id)")
            NetworkManager.shared.fetchElementCollection(to: .user, doc: id, model: User.self) { user in
                if let user = user {
                    print("Kарточка пользователя из сети загружена \(id)")
                    let userAPP = self.convertToUserAPP(user: user)
                        completion(userAPP)
                } else {
                    print("Ошибка загрузки карточки пользователя из сети \(id)")
                    completion(nil)
                }
            }
        }
    }
    
    //MARK: - обновление карточки пользователя
    func updateUser(to userAPP: UserAPP, completion: @escaping(Bool) -> Void) {
        if let userID = userAPP.id {
            print("Обновление карточки пользователя \(userAPP.name) \(userID)")
            let userExport = self.convertToUser(userAPP: userAPP)
            upLoadUser(to: userID, user: userExport) { status in
                print("Статус сохранения \(status) карточки пользователя \(userAPP.name) \(userID)")
                completion(status)
            }
        }
    }
    
    //MARK: - обновление карточки пользователя
    func updateUserPhoto(to userAPP: UserAPP, completion: @escaping(Bool) -> Void) {
        let image = userAPP.image
        if let userID = userAPP.id {
            print("Обновление фото пользователя \(userAPP.name) \(userID)")
            FileAppManager.shared.loadFileData(to: image, type: .assets) { data in
                if let data = data {
                    NetworkManager.shared.upLoadFile(to: image, type: .image, data: data) { _ in
                        print("Сохранен файл image \(userAPP.name)")
                        let image = image as Any
                        NetworkManager.shared.updateValueElement(to: .user, document: userID, key: "image", value: image)
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            completion(false)
        }
    }
    
    //MARK: - создать и записать новый профиль в облако
    func createNewUser(to userAPP: UserAPP, completion: @escaping(Bool) -> Void) {
        print("Создание новой карточки пользователя \(userAPP.name)")
        let myGroup = DispatchGroup()
        let image = userAPP.image
        var user = convertToUser(userAPP: userAPP)
        
        myGroup.enter()
        FileAppManager.shared.loadFileData(to: image, type: .assets) { data in
            if let data = data {
                NetworkManager.shared.upLoadFile(to: image, type: .image, data: data) { file in
                    print("Сохранен файл image \(user.name)")
                    user.image = file
                    myGroup.leave()
                }
            } else {
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            print("Сохранен карточки пользователя \(user.name)")
            self.upLoadUser(to: nil, user: user) { status in
                completion(status)
            }
        }
    }
  
    // coding User to JSON standart UserCurrent
    private func convertToUserAPP(user: User) -> UserAPP {
        var current = UserAPP()
        current.id = user.id
        current.date = user.date
        current.isActive = user.isActive
        
        current.email = user.email
        current.phone = user.phone
        current.name = user.name
        current.surname = user.surname
        
        current.image = user.image
        current.role = user.role
        current.roles = user.roles
        current.stages = user.stages
        
        current.profile = user.profile
        return current
    }
    
    // encoding JSON standart UserCurrent to User
    private func convertToUser(userAPP: UserAPP) -> User {
        var user = User.getEmptyUser()
        user.id = userAPP.id
        user.date = userAPP.date
        user.isActive = userAPP.isActive
        
        user.email = userAPP.email
        user.phone = userAPP.phone
        user.name = userAPP.name
        user.surname = userAPP.surname
        
        user.image = userAPP.image
        user.role = userAPP.role
        user.roles = userAPP.roles
        user.stages = userAPP.stages
        
        user.profile = userAPP.profile
        return user
    }

    //MARK: - методы работы с пользователем USER
    // сохранение пользователя
    func upLoadUser(to id: String?, user: User?, completion: @escaping (Bool) -> Void) {
        let name = id != nil ? id : AuthUserManager.shared.currentUserID()
        if let user = user, let name = name {
            let data = ["id:" : name,
                        "date" : user.date,
                        "isActive" : user.isActive,
                        
                        "email" : user.email,
                        "phone" : user.phone,
                        "name" : user.name,
                        "surname" : user.surname,
                        
                        
                        "image" : user.image,
                        "role" : user.role,
                        "roles" : user.roles,
                        "stages" : user.stages,
                        
                        "profile" : user.profile ] as [String : Any]
            NetworkManager.shared.upLoadElementCollection(to: .user, name: name, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }
    // получить имя пользователя
    func getNameUser(to id: String, completion: @escaping (String?) -> Void) {
        StorageManager.shared.load(type: .user, model: UserAPP.self) { user in
            if let user = user {
                let name = user.name
                let surname = " " + user.surname
                completion(name + surname)
            } else {
                NetworkManager.shared.fetchElementCollection(to: .user, doc: id, model: User.self) { user in
                    if let user = user {
                        let name = user.name
                        let surname = " " + user.surname
                        completion(name + surname)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
}
