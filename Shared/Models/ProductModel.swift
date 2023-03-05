//
//  ProductModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//
//  Справочник готовых изделий cloud fb

import Foundation

struct Product: Codable {
    var id: String = UUID().uuidString
    var date: String = Date().timeStamp()
    var idUser: String = ""
    var idGroup: String = ""
    var isActive: Bool = true
    var countUse: Int = 0
    
    var sort: Int = 0
    var article: String = ""
    var name: String = ""
    var label: String = ""
    var file: String = ""
    var images: [String: Int] = [:]
    var process: [String: Int] = [:]
}

struct ProductAPP: Codable {
    var id: String = UUID().uuidString
    var date: String = Date().timeStamp()
    var idUser: String = ""
    var idGroup: String = ""
    var isActive: Bool = true
    var countUse: Int = 0
    
    var sort: Int = 0
    var article: String = ""
    var name: String = ""
    var label: String = ""
    var file = Data()
    var images: [String: Int] = [:]
    var process: [String: Int] = [:]
}
