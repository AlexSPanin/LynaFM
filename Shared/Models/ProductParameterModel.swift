//
//  ProductParameterModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//
//  Справочник параметров товара cloud fb

import Foundation

struct ProductParameter: Codable {
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

struct ProductParameterAPP: Codable {
    var id: String = ""
    var date: String = ""
    var idUser: String = ""
    var isActive: Bool = true
    var countUse: Int = 0
    
    var sort: String = ""
    var name: String = ""
    var label: String = ""
    var file = Data()
}
