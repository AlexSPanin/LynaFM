//
//  ContentView.swift
//  Shared
//
//  Created by Александр Панин on 18.01.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var navigation: NavigationViewModel
    
    var body: some View {
        
        ZStack {
            switch navigation.showView {
            case .auth:
                AuthView(systemAPP: navigation.systemStorage)
            case .load:
                LoadView(label: navigation.title)
            case .error:
                ErrorView(label: navigation.title)
            case .admin:
                AdminAppView()
            case .order:
                ErrorView(label: navigation.title)
            case .stage:
                ErrorView(label: navigation.title)
            }
        }
    }
}

