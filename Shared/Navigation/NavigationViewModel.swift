//
//  NavigationViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import Foundation
enum Navigation {
    case auth
    case role
}

class NavigationViewModel: ObservableObject {
    
    @Published var view = Navigation.auth
    
    init() {
        print("START: NavigationViewModel")
    }
    deinit {
        print("CLOSE: NavigationViewModel")
    }
}
