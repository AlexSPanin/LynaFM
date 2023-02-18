//
//  AdminAppViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import Foundation
enum AdminAppViews: Codable {
    case user, card, product, material, property, start, stage, parameter, group
}

enum TapButtonAdminApp: Codable {
    case addUser
}

class AdminAppViewModel: ObservableObject {
    @Published var showView: AdminAppViews = .start {
        didSet {
            switch showView {
            case .user:
                label = "Справочник пользователей"
            case .card:
                label = "Справочник тех. карт"
            case .product:
                label = "Справочник продуктов"
            case .material:
                label = "Справочник материалов"
            case .property:
                label = "Справочники приложения"
            case .start:
                label = "Настройка справочников"
            case .stage:
                label = "Справочник производственных этапов"
            case .parameter:
                label = "Справочник параметров"
            case .group:
                label = "Справочник товарных групп"
            }
        }
    }
    
    @Published var label = "Настройка справочников"
    @Published var isExit = false {
        didSet {
            print("Сменить профиль пользователя")
        }
    }
    
    init() {
        print("START: AdminAppViewModel")
    }
    deinit {
        print("CLOSE: AdminAppViewModel")
    }
    
   
    
    
}
