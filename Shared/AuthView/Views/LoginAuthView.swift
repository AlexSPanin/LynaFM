//
//  LoginAuthView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct LoginAuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    private let title = language == "RUS" ? "Введите email и пароль" : "Enter Email and Password"
    private let password = language == "RUS" ? "Введите пароль" : "Enter Password"
   
    var body: some View {
        ZStack {
        VStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(fontN)
                .lineLimit(1)
                .minimumScaleFactor(scale)
                .multilineTextAlignment(.leading)
            
            TextFieldView(subtitle: "Email",
                          tipeTextField: .login, text: $viewModel.email)
            TextFieldView(subtitle: password,
                          tipeTextField: .password, text: $viewModel.password)
            
        }
        .padding(.all, hPadding)
        .frame(width: screen)
        .background(
            Color.accentColor.opacity(0.1).cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(mainColor, lineWidth: 1)
                )
        )
            ReturnAndSaveButton(disableSave: false,
                                disableBack: false) {
                viewModel.isAuth.toggle()
            } actionBack: {
                viewModel.showView = .repair
            }
        }
    }
}
