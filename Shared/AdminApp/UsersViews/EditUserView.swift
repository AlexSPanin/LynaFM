//
//  EditUserView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import SwiftUI

struct EditUserView: View {
    @ObservedObject var viewModel: UsersAdminAppViewModel
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack {
                TopLabelButtonView(label: viewModel.label) {
                    viewModel.showEditUser.toggle()
                }
                VStack {
                    TextFieldView(subtitle: "Имя",
                                  tipeTextField: .userName, text: $viewModel.name)
                    TextFieldView(subtitle: "Фамилия",
                                  tipeTextField: .userName, text: $viewModel.surname)
                    TextFieldView(subtitle: "Телефон",
                                  tipeTextField: .userName, text: $viewModel.phone)
                    HStack {
                    Text("Роли пользователя:")
                        .font(.footnote)
                        .foregroundColor(.accentColor)
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)
                        Spacer()
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(viewModel.userData.roles.sorted(by: {$0.key.sort < $1.key.sort}), id: \.key.sort) { key, value in
                            Button {
                                viewModel.userData.roles[key]?.toggle()
                            } label: {
                                UserRoleLineView(status: value, role: key)
                            }
                        }
                    }

                    VStack {
                        CustomButton(text: "Сохранить", width: WIDTH * 0.4) {
                            viewModel.press = .editUser
                        }
                        HorizontalDividerLabelView(label: "или")
                        TextButton(text: "Закрыть") {
                            viewModel.showEditUser.toggle()
                        }
                    }
                    .padding(.top, hPadding)
                }
                .disabled(!viewModel.isActiveEdit)
                .padding(.top, 100)
                .padding(.horizontal, hPadding)
            }
        }
    }
}


