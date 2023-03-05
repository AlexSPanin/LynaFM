//
//  GroupModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//
//  Справочник групп для продуктов cloud fb

import Foundation

struct Group: Codable {
    var id: String = UUID().uuidString
    var date: String = Date().timeStamp()
    var idUser: String = ""
    var isActive: Bool = true
    var countUse: Int = 0
    
    var type: String = ""
    var preGroup: String = ""
    var afterGroup: [String] = []
    
    var sort: Int = 0
    var name: String = ""
    var label: String = ""
    var image: String = ""
}
