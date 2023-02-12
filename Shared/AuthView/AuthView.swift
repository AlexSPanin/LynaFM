//
//  AuthView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import SwiftUI

struct AuthView: View {
    
    @StateObject var viewModel = AuthViewModel()
    let checkList: [NetworkCollection: CheckLine]
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
                ErrorView(label: viewModel.label)
            case .starting:
                StartingView(viewModel: viewModel)
            case .exit:
                ErrorView(label: viewModel.label)
            case .create:
                UpdateUserView(viewModel: viewModel)
            }

            // отработка сообщений об ошибках
            if viewModel.errorOccured {
                NotificationView(text: viewModel.errorText, button: "ОК", button2: nil) {
                    viewModel.errorOccured.toggle()
                } action2: {}
            }
        }
        .onAppear {
            viewModel.checkList = checkList
            viewModel.isStart.toggle()
        }
    }
}
