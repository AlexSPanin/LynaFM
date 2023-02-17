//
//  TypeKey.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 17.02.2023.
//

import Foundation

enum TypeKey: Codable {
    case system, users, user, stages, groups, parameters, materials, products
    var key: String {
        switch self {
        case .system:
            return "keySystem"
        case .users:
            return "keyUsers"
        case .user:
            return "keyCurrent"
        case .stages:
            return "keyStages"
        case .groups:
            return "keyGroups"
        case .parameters:
            return "keyParametrs"
        case .materials:
            return "keyMaterials"
        case .products:
            return "keyProducts"
        }
    }
}
