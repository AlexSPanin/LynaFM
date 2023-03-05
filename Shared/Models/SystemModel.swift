//
//  SystemModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 16.02.2023.
//
//MARK: -  модель системных баз
import Foundation
struct SystemApp: Codable, Hashable {
    var ver = ""
    var user = ""
    var product = ""
    var material = ""
    var bundle = ""
    var group = ""
    var parameter = ""
    var stage = ""
}
