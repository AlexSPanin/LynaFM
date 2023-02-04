//
//  RecoveryUser.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct RecoveryUserView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Введите email")
                .font(.body)
                .lineLimit(1)
                .minimumScaleFactor(scaleFactor)
                .multilineTextAlignment(.leading)
            
            TextFieldView(subtitle: "Email",
                          tipeTextField: .login, text: $viewModel.userAPP.email)
            
            VStack {
                CustomButton(text: "Отправить", width: WIDTH * 0.4) {
                    viewModel.isSendRecovery.toggle()
                }
                HorizontalDividerLabelView(label: "или")
                TextButton(text: "Выйти") {
                    viewModel.showView = .auth
                }
            }
            .padding(.top, hPadding)
        }
        .padding(.all, hPadding)
        .frame(width: WIDTH * 0.95)
        .background(
            Color.accentColor.opacity(0.1).cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor, lineWidth: 1)
                )
        )
    }
}
