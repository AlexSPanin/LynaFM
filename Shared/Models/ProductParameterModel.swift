//
//  ProductParameterModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//
//  Справочник параметров товара cloud fb

import Foundation

struct ParameterAPP: Codable {
    var parameter = Parameter()
    var elements = [ParameterElement]()
}

struct Parameter: Codable {
    var id: String = ""
    var date: String = ""
    var idUser: String = ""
    var isActive: Bool = true
    var countUse: Int = 0
    
    var sort: Int = 0
    var type: String = ""
    var name: String = ""
    var label: String = ""
    var images: [String] = []
    var files: [String] = []
}

struct ParameterElement: Codable {
    var id: String = ""
    var idCollection: String = ""
    var date: String = ""
    var idUser: String = ""
    var isActive: Bool = true
    var countUse: Int = 0
    
    var sort: Int = 0
    var name: String = ""
    var value: String = ""
    var images: [String] = []
    var files: [String] = []
}
