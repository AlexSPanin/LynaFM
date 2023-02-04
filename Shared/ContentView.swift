//
//  ContentView.swift
//  Shared
//
//  Created by Александр Панин on 18.01.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var navigation: NavigationViewModel
    
    var body: some View {
        
        ZStack {
            switch navigation.view {
            case .auth:
                AuthView(checkList: navigation.checkList) 
            case .load:
                LoadView(label: navigation.label)
            case .error:
                ErrorView(label: navigation.label)
            case .admin:
                AdminAppView()
            case .order:
                ErrorView(label: navigation.label)
            case .stage:
                ErrorView(label: navigation.label)
            }
        }
    }
}

