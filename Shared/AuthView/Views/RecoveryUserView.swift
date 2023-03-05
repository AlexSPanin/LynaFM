//
//  RecoveryUser.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct RecoveryUserView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        ZStack {
        VStack(alignment: .center, spacing: 10) {
            Text(TypeMessage.enterEmail.label)
                .font(fontN)
                .lineLimit(1)
                .minimumScaleFactor(scale)
                .multilineTextAlignment(.leading)
            
            TextFieldView(subtitle: "Email",
                          tipeTextField: .login, text: $viewModel.email)
        }
        .padding(.all, hPadding)
        .frame(width: screen)
        .background(
            mainLigth.cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(mainColor, lineWidth: 1)
                )
        )
            ReturnAndSaveButton(disableSave: false,
                                disableBack: false) {
                viewModel.isSendRecovery.toggle()
            } actionBack: {
                viewModel.showView = .auth
            }
        }
    }
}
