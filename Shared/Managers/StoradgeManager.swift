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
    func saveUser(at user: UserCurrent) {
        do {
            let data = try JSONEncoder().encode(user)
            userDefaults.set(data, forKey: TypeKey.user.key)
        } catch {
            print("ERROR: JSON - not save User")
        }
    }
}

////MARK: - coding and decoding User Model
//extension StorageManager {
//    
//    // coding User to JSON standart UserCurrent
//    private func getUserToUserCurrent(user: User) -> UserCurrent {
//        var userCurrent = UserCurrent()
//        userCurrent.id = user.id
//        userCurrent.isStudy = user.isStudy
//        userCurrent.isAdmin = user.isAdmin
//        userCurrent.email = user.email
//        userCurrent.fullName = user.fullName
//        userCurrent.date = user.date
//        userCurrent.scoreAll = user.scoreAll
//        userCurrent.ratingAll = user.ratingAll
//        userCurrent.scoreMonth = user.scoreMonth
//        userCurrent.ratingMonth = user.ratingMonth
//        userCurrent.profileUrl = user.profileUrl
//        return userCurrent
//    }
//    // encoding JSON standart UserCurrent to User
//    private func getUserCurrentToUser(userCurrent: UserCurrent) -> User {
//        var user = User.getUser()
//        user.id = userCurrent.id
//        user.isStudy = userCurrent.isStudy
//        user.isAdmin = userCurrent.isAdmin
//        user.email = userCurrent.email
//        user.fullName = userCurrent.fullName
//        user.date = userCurrent.date
//        user.scoreAll = userCurrent.scoreAll
//        user.ratingAll = userCurrent.ratingAll
//        user.scoreMonth = userCurrent.scoreMonth
//        user.ratingMonth = userCurrent.ratingMonth
//        user.profileUrl = userCurrent.profileUrl
//        return user
//    }
//    
//}
