//
//  MaterialModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//
//  Справочник материалов cloud fb

import Foundation

struct Material: Codable {
    var id: String = ""
    var date: String = ""
    var idUser: String = ""
    var idGroup: String = ""
    var isActive: Bool = true
    var countUse: Int = 0
    
    var sort: String = ""
    var article: String = ""
    var name: String = ""
    var label: String = ""
    var file: String = ""
    var images: [String: Int] = [:]
}

struct MaterialAPP: Codable {
    var id: String = ""
    var date: String = ""
    var idUser: String = ""
    var idGroup: String = ""
    var isActive: Bool = true
    var countUse: Int = 0
    
    var sort: String = ""
    var article: String = ""
    var name: String = ""
    var label: String = ""
    var file = Data()
    
    // первое имя файла - второе сортировка
    var images: [String: Int] = [:]
}
