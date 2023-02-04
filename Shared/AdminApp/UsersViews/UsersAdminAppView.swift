//
//  UsersView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import SwiftUI

struct UsersAdminAppView: View {
    @ObservedObject var viewModelAdmin: AdminAppViewModel
    @StateObject var viewModel = UsersAdminAppViewModel()
    var body: some View {
        ZStack {
            TopLabelView(label: viewModel.label)
            
            VStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(viewModel.users, id: \.id) { user in
                            Button {
                                viewModel.user = user
                                viewModel.showEditUser.toggle()
                            } label: {
                                UserLineView(user: user)
                            }
                        }
                    }
                    .padding(.top, hPadding)
                    Spacer()
                    
                }
                .frame(width: WIDTH * 0.95, height: WIDTH * 0.6)
                .background(
                    Color.accentColor.opacity(0.05).cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 1)
                        )
                )
                
                VStack {
                    HorizontalDividerLabelView(label: "или")
                    HStack(alignment: .center, spacing: 20) {
                        TextButton(text: "Вернуться") {
                            viewModelAdmin.showView = .start
                        }
//                        TextButton(text: "Добавить пользователя") {
//                            viewModel.showAddUser.toggle()
//                        }
                    }
                }
                .padding(.top, hPadding)
                Spacer()
            }
            .padding(.top, 100)
        }
        .sheet(isPresented: $viewModel.showAddUser) {
            CreateUserView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showEditUser) {
            EditUserView(viewModel: viewModel)
        }
    }
}

