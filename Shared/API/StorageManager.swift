//
//  StoradgeManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation

enum TypeKey: Codable {
    case system, users, user
    var key: String {
        switch self {
        case .system:
            return "keySystem"
        case .users:
            return "keyUsers"
        case .user:
            return "keyCurrent"
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
        print("Начало сохранения коллекции в память \(type.key)")
        if let collection = collection as? T {
            do {
                let data = try JSONEncoder().encode(collection)
                userDefaults.set(data, forKey: type.key)
            } catch {
                print("Ошибка сохранения в память \(type.key)")
            }
        }
    }
    
    func remove(type: TypeKey) {
        userDefaults.removeObject(forKey: type.key)
    }
}

//MARK: - coding and decoding User Model
extension StorageManager {
    func convertToUsersApp(users: [User]) -> [UserAPP] {
        var usersAPP = [UserAPP]()
        users.forEach { user in
           let userAPP = convertToUserAPP(user: user)
            usersAPP.append(userAPP)
        }
        return usersAPP
    }
    
    func convertToUsers(usersAPP: [UserAPP]) -> [User] {
        var users = [User]()
        usersAPP.forEach { userAPP in
           let user = convertToUser(userAPP: userAPP)
            users.append(user)
        }
        return users
    }
    
    // coding User to JSON standart UserCurrent
    func convertToUserAPP(user: User) -> UserAPP {
        var current = UserAPP()
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
    func convertToUser(userAPP: UserAPP) -> User {
        var user = User.getUser(email: userAPP.email,
                                phone: userAPP.phone,
                                name: userAPP.name,
                                surname: userAPP.surname)
        user.id = userAPP.id
        user.isActive = userAPP.isActive
        user.date = userAPP.date
        user.image = userAPP.image
        user.profile = userAPP.profile
        return user
    }
    
}
