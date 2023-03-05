//
//  UserModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation

// модель пользователя
struct UserAPP: Codable {
    var id = UUID().uuidString
    var date = Date().timeStamp()
    var idUser = ""
    
    var isActive = true
   
    var email = ""
    var phone = ""
    var name = ""
    var surname = ""
    
    var image = ""
    var role = ""
    var roles = [String]()
    var stages = [String]()
    
    var profile = ""
}


