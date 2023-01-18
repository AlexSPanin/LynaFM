//
//  UserModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation
import FirebaseFirestoreSwift
// роли пользователей
enum UserRole: Codable {
    case owner, adminApp, adminOrder, adminStage
    
    var role: String {
        switch self {
        case .owner:
            return "owner"
        case .adminApp:
            return "adminApp"
        case .adminOrder:
            return "adminOrder"
        case .adminStage:
            return "adminStage"
        }
    }
}

// модель пользователя для внешнего хранения
struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var date = Date().rusDateShort()
    
    var isActive = true
   
    var email: String
    var phone: String
    var name: String
    var surname: String
    
    var image = ""
    var data = ""
    
    static func getUser(email: String, phone: String, name: String, surname: String) -> User {
       return  User(email: email, phone: phone, name: name, surname: surname)
    }
}

// набор ролей и привязанных этапов пользователя
struct UserData: Codable {
    var roles: [UserRole] = []
    var stages: [String] = []
}

// модель пользователя для UserDefaults
struct UserCurrent: Codable {
    var id: String?
    var date = ""
    
    var isActive = true
    
    var email = ""
    var phone = ""
    var name = ""
    var surname = ""
    
    var image = Data()
    var data = UserData()
}
