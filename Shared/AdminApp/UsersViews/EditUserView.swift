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
        ZStack {
            TopLabelButtonView(label: viewModel.label) {
                viewModel.showEditUser.toggle()
            }
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    VStack (spacing: 5){
                    TextFieldView(subtitle: "Имя",
                                  tipeTextField: .userName, text: $viewModel.user.name)
                    TextFieldView(subtitle: "Фамилия",
                                  tipeTextField: .userName, text: $viewModel.user.surname)
                    TextFieldView(subtitle: "Телефон",
                                  tipeTextField: .userName, text: $viewModel.user.phone)
                    }
                    .padding(.all, hPadding)
                    
                    List {
                        Section("Роли пользователя:") {
                            ForEach(0..<UserRole.allCases.count, id: \.self) { index in
                                Button {
                                    viewModel.changeRoleUser(to: UserRole.allCases[index])
                                } label: {
                                    UserRoleLineStatusView(index: index, strings: viewModel.user.roles)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: HEIGHT * 0.25)
                    
                    List {
                        Section("Этапы производства:") {
                            ForEach(0..<viewModel.stages.count, id: \.self) { index in
                                Button {
                                    viewModel.changeStageUser(to: viewModel.stages[index])
                                } label: {
                                    UserStageLineStatusView(index: index, strings: viewModel.user.stages, stages: viewModel.stages)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: HEIGHT * 0.25)
                    .padding(.vertical, hPadding)
                    
                    ReturnAndSaveButton(disableSave: false,
                                        disableBack: false) {
                        viewModel.isEditUser.toggle()
                    } actionBack: {
                        viewModel.showEditUser.toggle()
                    }

                    .padding(.bottom, hPadding)
                }
            }
            .padding(.top, 60)
            if viewModel.errorOccured {
                NotificationView(text: viewModel.errorText, button: "ОК", button2: nil) {
                    viewModel.errorOccured.toggle()
                } action2: { }
            }
        }
    }
}



