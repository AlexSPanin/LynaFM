//
//  TypeField.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 17.02.2023.
//

import SwiftUI

enum TypeField: Codable, CaseIterable {
    case number, text, color
    var label: String {
        switch self {
        case .number:
            return "Число"
        case .text:
            return "Текст"
        case .color:
            return "Цвет"
        }
    }
}
