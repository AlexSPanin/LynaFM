//
//  TypeGroup.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.02.2023.
//

import Foundation

enum TypeGroup: Codable, CaseIterable {
    case product, material
    var label: String {
        switch self {
        case .product:
            return "Готовые изделия"
        case .material:
            return "Материалы"
        }
    }
}
