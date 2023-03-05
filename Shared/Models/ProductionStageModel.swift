//
//  ProductionStageModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//  Справочник производственных этапов cloud fb

import Foundation

struct ProductionStage: Codable {
    var id: String = UUID().uuidString
    var date: String = Date().timeStamp()
    var idUser: String = ""
    var isActive: Bool = true
    var countUse: Int = 0
    
    var sort: Int = 0
    var name: String = ""
    var label: String = ""
}
