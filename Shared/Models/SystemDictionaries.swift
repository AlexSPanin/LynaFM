//
//  SystemDictionaries.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//

import Foundation

enum ProductType: CaseIterable, Codable {
    case material, part, product, bundle
}

enum MeasureUnit: CaseIterable, Codable {
    case piece, weight, length, square, volume, times
    var name: String {
        switch self {
        case .piece:
            return "штуки"
        case .weight:
            return "вес"
        case .length:
            return "длина"
        case .square:
            return "площадь"
        case .volume:
            return "объем"
        case .times:
            return "время"
        }
    }
    
    var label: String {
        switch self {
        case .piece:
            return "шт."
        case .weight:
            return "кг."
        case .length:
            return "м."
        case .square:
            return "м2."
        case .volume:
            return "м3."
        case .times:
            return "мин."
        }
    }
}


