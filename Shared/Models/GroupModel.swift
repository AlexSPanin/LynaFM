//
//  GroupModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//
//  Справочник групп для продуктов cloud fb

import Foundation

struct Group: Codable {
    var id: String = ""
    var date: String = ""
    var idUser: String = ""
    var isActive: Bool = true
    var countUse: Int = 0
    
    var sort: String = ""
    var name: String = ""
    var label: String = ""
    var file: String = ""
}
