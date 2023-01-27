//
//  ProductModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//
//  Справочник готовых изделий cloud fb

import Foundation

struct Product: Codable {
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
    var images: [String] = []
    var process: [String] = []
}