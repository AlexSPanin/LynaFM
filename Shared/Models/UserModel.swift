//
//  UserModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation
import FirebaseFirestoreSwift

// роли пользователей
enum UserRole: CaseIterable, Codable {
    case owner, app, order, stage, admin
    
    var role: String {
        switch self {
        case .owner:
            return "owner"
        case .app:
            return "app"
        case .order:
            return "order"
        case .stage:
            return "stage"
        case .admin:
            return "admin"
        }
    }
    
    var sort: String {
        switch self {
        case .owner:
            return "B"
        case .app:
            return "C"
        case .order:
            return "D"
        case .stage:
            return "E"
        case .admin:
            return "A"
        }
    }
    
    var label: String {
        switch self {
        case .owner:
            return "Владелец"
        case .app:
            return "Администратор Приложения"
        case .order:
            return "Администратор Заказов"
        case .stage:
            return "Администратор Участка"
        case .admin:
            return "Администратор"
        }
    }
}

// модель пользователя для внешнего хранения
struct User: Identifiable,  Codable {
  @DocumentID var id: String?
    var date = Date().timeStamp()
    
    var isActive = true
   
    var email: String
    var phone: String
    var name: String
    var surname: String
    
    var image = ""
    var profile = ""
    
    static func getUser(email: String, phone: String, name: String, surname: String) -> User {
       return  User(email: email, phone: phone, name: name, surname: surname)
    }
    
    static func getEmptyUser() -> User {
       return  User(email: "", phone: "", name: "", surname: "")
    }
}

// модель пользователя для внешнего хранения
struct UserAPP: Codable {
    var id: String?
    var date = ""
    
    var isActive = true
   
    var email = ""
    var phone = ""
    var name = ""
    var surname = ""
    
    var image = Data()
    var profile = UserData()
    

}

// набор ролей и привязанных этапов пользователя
struct UserData: Codable {
    var roles: [UserRole: Bool] = [:]
    var stages: [String] = []
}

