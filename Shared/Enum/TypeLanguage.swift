//
//  TypeLanguage.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.03.2023.
//

import Foundation
enum TypeLanguage: CaseIterable, Codable {
    case rus
    case eng
    var label: String {
        switch self {
        case .rus:
            return "RUS"
        case .eng:
            return "EN"
        }
    }
    var sort: Int {
        switch self {
        case .rus:
            return 0
        case .eng:
            return 1
        }
    }
}
