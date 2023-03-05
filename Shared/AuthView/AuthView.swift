//
//  AuthView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var systemAPP: SystemApp?
    var body: some View {
        ZStack {
            switch viewModel.showView {
            case .auth:
                LoginAuthView()
            case .edit:
                EditProfileUserView()
            case .repair:
                RecoveryUserView()
            case .error:
                ErrorView(label: viewModel.title)
            case .starting:
                StartingView()
            case .exit:
                ErrorView(label: viewModel.title)
            }

            // отработка сообщений об ошибках
            if viewModel.errorOccured {
                NotificationView(text: viewModel.errorText, button: "ОК", button2: nil) {
                    viewModel.errorOccured.toggle()
                } action2: {}
            }
        }
        .onAppear {
            viewModel.systemAPP = systemAPP
            viewModel.isStart.toggle()
        }
    }
}
