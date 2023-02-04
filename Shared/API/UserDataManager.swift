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
    //MARK: - загрузка карточки пользователя
    func loadUser(to id: String, completion: @escaping(Result<UserAPP, NetworkError>) -> Void) {
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
    
    //MARK: - обновление карточки пользователя
    func updateUser(to userAPP: UserAPP) {
        print("Обновление карточки пользователя \(userAPP.name)")
        let myGroup = DispatchGroup()
        if let userID = userAPP.id {
            NetworkManager.shared.fetchElementCollection(to: .user, doc: userID, model: User.self) { [self] result in
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
                    let userExport = convertToUser(userAPP: userAPP)
                    myGroup.notify(queue: .main) {
                        print("Сохранение обновленной карточки пользователя \(userAPP.name)")
                        NetworkManager.shared.upLoadUser(to: nil, user: userExport)
                    }
                case .failure(_):
                    print("Ошибка загрузки карточки пользователя из сети \(userAPP.name)")
                }
            }
        }
    }
    
    //MARK: - создать и записать новый профиль в облако
    func createNewUser(name: String, surname: String, phone: String, email: String, completion: @escaping(UserAPP) -> Void) {
        print("Создание новой карточки пользователя \(name)")
        let myGroup = DispatchGroup()
        let userData = createUserData()
        let logo = Data()
        var user = User(email: email, phone: phone, name: name, surname: surname)
        myGroup.enter()
        NetworkManager.shared.upLoadFile(type: .user, model: UserData.self, collection: userData) { file in
            print("Сохранен файл userData \(name)")
            user.profile = file
            myGroup.leave()
        }
        myGroup.enter()
        NetworkManager.shared.upLoadFile(type: .user, data: logo) { file in
            print("Сохранен файл image \(name)")
            user.image = file
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            print("Сохранен карточки пользователя \(name)")
            NetworkManager.shared.upLoadUser(to: nil, user: user)
            self.convertToUserAPP(user: user, completion: { userAPP in
                completion(userAPP)
            })
        }
    }
    
    //MARK: -  создание пустой UserData
    private func createUserData() -> UserData {
        var userData = UserData()
        UserRole.allCases.forEach { role in
            userData.roles[role] = false
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
        var user = User.getUser(email: userAPP.email,
                                phone: userAPP.phone,
                                name: userAPP.name,
                                surname: userAPP.surname)
        user.id = userAPP.id
        user.isActive = userAPP.isActive
        user.date = userAPP.date
        return user
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
