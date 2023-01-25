//
//  ProductionStageModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//  Справочник производственных этапов cloud fb

import Foundation

struct ProductionStage {
    var id: String = ""
    var date: String = ""
    var idUser: String = ""
    var sort: String = ""
    var name: String = ""
    var label: String = ""
    var isActive: Bool = true
    var countUse: Int = 0
}
