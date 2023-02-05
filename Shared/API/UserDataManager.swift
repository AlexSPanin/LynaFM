//
//  UserDataManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 04.02.2023.
//
//MARK: - методы для работы с профилем пользователя
import Foundation

class UserDataManager {
    static let shared = UserDataManager()
    private init() {}
    //MARK: - загрузка всех карточк пользователей
    func loadUsers(completion: @escaping(Result<[UserAPP], NetworkError>) -> Void) {
        print("Загрузка карточек пользователей")
        let myGroup = DispatchGroup()
        NetworkManager.shared.fetchFullCollection(to: .user, model: User.self) { result in
            switch result {
            case .success(let users):
                print("Коллекция из сети загружена Users Collection")
                var usersAPP = [UserAPP]()
                users.forEach { user in
                    myGroup.enter()
                    self.loadUser(to: user.id) { result in
                        switch result {
                        case .success(let userAPP):
                            usersAPP.append(userAPP)
                            myGroup.leave()
                        case .failure(_):
                            print("Ошибка загрузки Пользователя \(user.name) \(user.surname)")
                            myGroup.leave()
                        }
                    }
                }
                myGroup.notify(queue: .main) {
                    completion(.success(usersAPP))
                }
            case .failure(_):
                print("Ошибка: сбой обнавления коллекции.\nОбратитесь к администратору.")
                completion(.failure(.fetchCollection))
            }
        }
    }
    
    //MARK: - загрузка карточки пользователя
    func loadUser(to id: String?, completion: @escaping(Result<UserAPP, NetworkError>) -> Void) {
        if let id = id {
            print("Загрузка карточки пользователя \(id)")
            NetworkManager.shared.fetchElementCollection(to: .user, doc: id, model: User.self) { [self] result in
                switch result {
                case .success(let user):
                    convertToUserAPP(user: user, completion: { userAPP in
                        completion(.success(userAPP))
                    })
                case .failure(_):
                    print("Ошибка загрузки карточки пользователя из сети \(id)")
                    completion(.failure(.fetchUser))
                }
            }
        }
    }
    
    //MARK: - обновление карточки пользователя
    func updateUser(to userAPP: UserAPP, completion: @escaping(Bool) -> Void) {
        
        let myGroup = DispatchGroup()
        if let userID = userAPP.id {
            print("Обновление карточки пользователя \(userAPP.name) \(userID)")
            NetworkManager.shared.fetchElementCollection(to: .user, doc: userID, model: User.self) { result in
                switch result {
                case .success(let user):
                    myGroup.enter()
                    NetworkManager.shared.upLoadFile(to: user.profile, type: .user, model: UserData.self, collection: userAPP.profile) { _ in
                        print("Сохранен файл userData \(userAPP.name)")
                        myGroup.leave()
                    }
                    myGroup.enter()
                    NetworkManager.shared.upLoadFile(to: user.image, type: .user, data: userAPP.image) { _ in
                        print("Сохранен файл image \(userAPP.name)")
                        myGroup.leave()
                    }
                    var userExport = self.convertToUser(userAPP: userAPP)
                    userExport.profile = user.profile
                    userExport.image = user.image
                    myGroup.notify(queue: .main) {
                        NetworkManager.shared.upLoadUser(to: userID, user: userExport) { status in
                            print("Статус сохранения \(status) карточки пользователя \(userAPP.name) \(userID)")
                            completion(status)
                        }
                    }
                case .failure(_):
                    print("Ошибка загрузки карточки пользователя из сети \(userAPP.name)")
                    completion(false)
                }
            }
        }
    }
    
    //MARK: - создать и записать новый профиль в облако
    func createNewUser(to userAPP: UserAPP, completion: @escaping(Bool) -> Void) {
        print("Создание новой карточки пользователя \(userAPP.name)")
        let myGroup = DispatchGroup()
        let image = userAPP.image
        var user = convertToUser(userAPP: userAPP)
        
        myGroup.enter()
        NetworkManager.shared.upLoadFile(type: .user, model: UserData.self, collection: userAPP.profile) { file in
            print("Сохранен файл userData \(user.name)")
            user.profile = file
            myGroup.leave()
        }
        myGroup.enter()
        NetworkManager.shared.upLoadFile(type: .user, data: image) { file in
            print("Сохранен файл image \(user.name)")
            user.image = file
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            print("Сохранен карточки пользователя \(user.name)")
            NetworkManager.shared.upLoadUser(to: nil, user: user) { status in
                completion(status)
            }
        }
    }
    
    //MARK: -  создание пустой UserData
    func createUserData() -> UserData {
        var userData = UserData()
        UserRole.allCases.forEach { role in
            // ВНИМАНИЕ потом заменить на false
            userData.roles[role] = true
        }
        return userData
    }
    
    // coding User to JSON standart UserCurrent
    private func convertToUserAPP(user: User, completion: @escaping(UserAPP) -> Void) {
        let myGroup = DispatchGroup()
        var current = UserAPP()
        current.id = user.id
        current.date = user.date
        current.isActive = user.isActive
        
        current.email = user.email
        current.phone = user.phone
        current.name = user.name
        current.surname = user.surname
        
        myGroup.enter()
        NetworkManager.shared.loadFile(type: .user, name: user.profile, model: UserData.self) { result in
            switch result {
            case .success(let profile):
               current.profile = profile
                myGroup.leave()
            case .failure(_):
                print("Ошибка загрузки файл userData \(user.name)")
                myGroup.leave()
            }
        }
        myGroup.enter()
        NetworkManager.shared.loadFile(type: .user, name: user.image) { result in
            switch result {
            case .success(let data):
                current.image = data
                myGroup.leave()
            case .failure(_):
                print("Ошибка загрузки файл image \(user.name)")
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
            print("Сохранение обновленной карточки пользователя \(user.name)")
           completion(current)
        }
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

        return user
    }

}
