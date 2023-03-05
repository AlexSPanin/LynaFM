//
//  CreateUserView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import SwiftUI

struct CreateUserView: View {
    @ObservedObject var viewModel: UsersAdminAppViewModel
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack {
                TopLabelButtonView(label: viewModel.label) {
                    viewModel.showAddUser.toggle()
                }
                VStack {
                    TextFieldView(subtitle: "Имя",
                                  tipeTextField: .userName, text: $viewModel.user.name)
                    TextFieldView(subtitle: "Фамилия",
                                  tipeTextField: .userName, text: $viewModel.user.surname)
                    TextFieldView(subtitle: "Телефон",
                                  tipeTextField: .userName, text: $viewModel.user.phone)
                    TextFieldView(subtitle: "Email",
                                  tipeTextField: .userName, text: $viewModel.user.email)
                    
                    HStack {
                    Text("Роли пользователя:")
                        .font(.footnote)
                        .foregroundColor(mainColor)
                        .minimumScaleFactor(scale)
                        .lineLimit(1)
                        Spacer()
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(0..<UserRole.allCases.count, id: \.self) { index in
                            Button {
                                viewModel.user.roles.append(UserRole.allCases[index].role)
                            } label: {
                                UserRoleLineStatusView(index: index, strings: viewModel.user.roles)
                            }
                        }
                    }
                    ReturnAndSaveButton(disableSave: false, disableBack: false) {
                        viewModel.isAddUser.toggle()
                    } actionBack: {
                        viewModel.showAddUser.toggle()
                    }
                    .padding(.top, hPadding)
                }
                .padding(.top, 100)
                .padding(.horizontal, hPadding)
                
                // отработка сообщений об ошибках
                if viewModel.errorOccured {
                    NotificationView(text: viewModel.errorText, button: "ОК", button2: nil) {
                        viewModel.errorOccured.toggle()
                    } action2: { }
                }
            }
        }
    }
}
