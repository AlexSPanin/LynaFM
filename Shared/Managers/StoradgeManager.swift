//
//  StoradgeManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation

enum TypeKey: Codable {
    case app, user, exit
    var key: String {
        switch self {
        case .app:
            return "keyApp"
        case .user:
            return "keyUser"
        case .exit:
            return "keyExit"
        }
    }
}


class StorageManager {
    
    static let shared = StorageManager()

    private init() {}
    
    // проверка и установка Bool ключей
    func checkKey(type: TypeKey) -> Bool {
        return userDefaults.bool(forKey: type.key)
    }
    
    func settingKey(to type: TypeKey, key: Bool) {
        userDefaults.set(key, forKey: type.key)
    }
    
    // получение из памяти модели пользователя
    func fetchUserCurrent(complition: @escaping(Result<UserCurrent, NetworkError>) -> Void) {
        if let data = userDefaults.object(forKey: TypeKey.user.key) as? Data {
            do {
                let userCurrent = try JSONDecoder().decode(UserCurrent.self, from: data)
                complition(.success(userCurrent))
            } catch {
                print("ERROR - Decode Fetch UserCurrent")
                complition(.failure(.decodeUser))
            }
        } else {
            complition(.failure(.fetchUser))
        }
    }
    
    // запись в память модели пользователя
    func saveUser(at user: UserCurrent?) {
        if let user = user {
            do {
                let data = try JSONEncoder().encode(user)
                userDefaults.set(data, forKey: TypeKey.user.key)
            } catch {
                print("ERROR: JSON - not save User")
            }
        }
    }
}

//MARK: - coding and decoding User Model
extension StorageManager {
    
    // coding User to JSON standart UserCurrent
    func getUserToUserCurrent(user: User) -> UserCurrent {
        var current = UserCurrent()
        current.id = user.id
        current.date = user.date
        current.isActive = user.isActive
        current.email = user.email
        current.phone = user.phone
        current.name = user.name
        current.surname = user.surname
        current.image = user.image
        current.profile = user.profile
        return current
    }
    // encoding JSON standart UserCurrent to User
    func getUserCurrentToUser(current: UserCurrent) -> User {
        var user = User.getUser(email: current.email,
                                phone: current.phone,
                                name: current.name,
                                surname: current.surname)
        user.id = current.id
        user.isActive = current.isActive
        user.date = current.date
        user.image = current.image
        user.profile = current.profile
        return user
    }
    
}
