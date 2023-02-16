//
//  NetworkCollection.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 16.02.2023.
//
//MARK: - перечисление коллекций в FB
import Foundation
enum NetworkCollection: String {
    case system = "system"
    case user = "user"
    case product = "product"
    case material = "material"
    case bundle = "bundle"
    case group = "group"
    case parameter = "parameter"
    case stage = "stage"
    case order = "order"
    case elements = "elements"
    
    var collection: String {
        return self.rawValue
    }
}
