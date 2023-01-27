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
                AuthView()
            case .role:
                RoleUserView()
            case .load:
                LoadDataBaseView(label: navigation.labelBase)
            case .error:
                ErrorView()
            case .version:
                VersionValidateView()
            }
        }
    }
}

