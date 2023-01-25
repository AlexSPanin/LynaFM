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
    
    // MARK: - проверка и установка Bool ключей
    func checkKey(type: TypeKey) -> Bool {
        return userDefaults.bool(forKey: type.key)
    }
    func settingKey(to type: TypeKey, key: Bool) {
        userDefaults.set(key, forKey: type.key)
    }
    
    // MARK: - запись и чтение по ключу и по типу модели (для кодирования)
    func load<T: Decodable>(type: TypeKey, model: T.Type, completion: @escaping(Result<T, NetworkError>) -> Void) {
        if let data = userDefaults.object(forKey: type.key) as? Data {
            do {
                let decoder = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoder))
            } catch {
                completion(.failure(.decodeStorage))
            }
        } else {
            completion(.failure(.loadStorage))
        }
    }

    func save<T: Encodable>(type: TypeKey, model: T.Type, collection: Any ) {
        if let collection = collection as? T {
            do {
                let data = try JSONEncoder().encode(collection)
                userDefaults.set(data, forKey: type.key)
            } catch {
                print("ERROR: Save File to Storage Manager")
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
