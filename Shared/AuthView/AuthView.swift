//
//  AuthView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var navigation: NavigationViewModel
    @StateObject var viewModel = AuthViewModel()
    var body: some View {
        ZStack {
            switch viewModel.showView {
            case .auth:
                LoginAuthView(viewModel: viewModel)
            case .edit:
                ProfileUserView(viewModel: viewModel)
            case .repair:
                RecoveryUserView(viewModel: viewModel)
            case .error:
                ErrorView()
            case .starting:
                StartingView(viewModel: viewModel)
            case .exit:
                ExitView()
            }

            // отработка сообщений об ошибках
            if viewModel.errorOccured {
                NotificationView(text: viewModel.errorText, button: "ОК") {
                    viewModel.errorOccured.toggle()
                }
            }
        }
        .onChange(of: viewModel.isFinish) { newValue in
            if newValue {
                navigation.view = .role
            }
        }
        
    }
}
