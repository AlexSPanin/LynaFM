//
//  AuthView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import SwiftUI

struct AuthView: View {
@StateObject var viewModel = AuthViewModel()
    var body: some View {
        ZStack {
        Text(viewModel.isVersion ? /*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/ : "Loading")
            if viewModel.errorOccured {
                NotificationView(text: viewModel.errorText, button: "ОК") {
                    viewModel.errorOccured.toggle()
                }
            }
        }
    }
}
