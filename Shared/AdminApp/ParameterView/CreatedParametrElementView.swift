//
//  CreatedParametrElementView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 16.02.2023.
//

import SwiftUI

struct CreatedParametrElementView: View {
    @ObservedObject var viewModel: ParameterAdminViewModel
    let isEditing: Bool
    var body: some View {
        ZStack {
            TopLabelButtonView(label: viewModel.label) {
                if isEditing {
                    viewModel.showEditElement.toggle()
                } else {
                    viewModel.showAddElement.toggle()
                }
            }
            ScrollView(.vertical, showsIndicators: true) {
                
                VStack {
                    TopCardView(isActive: $viewModel.isActiveElement,
                                date: viewModel.date,
                                user: viewModel.nameUser,
                                isEditing: isEditing)

                    // добавить признак активности
                    VStack {
                        TextFieldView(subtitle: "Наименование",
                                      tipeTextField: .simple, text: $viewModel.name)
                        TextFieldView(subtitle: "Параметр",
                                      tipeTextField: .simple, text: $viewModel.description)
                        
                        VStack {
                            CustomButton(text: "Сохранить", width: WIDTH * 0.4) {
                                if isEditing {
                                    viewModel.isEditElement.toggle()
                                } else {
                                    viewModel.isAddElement.toggle()
                                }
                            }
                            HorizontalDividerLabelView(label: "или")
                            TextButton(text: "Закрыть") {
                                if isEditing {
                                    viewModel.showEditElement.toggle()
                                } else {
                                    viewModel.showAddElement.toggle()
                                }
                            }
                            .foregroundColor(.cyan.opacity(0.8))
                        }
                    }
                    .padding(.all, hPadding)
                }
            }
            .padding(.top, 60)
            
            // отработка сообщений об ошибках
            if viewModel.errorOccured {
                if !viewModel.typeNote {
                    NotificationView(text: viewModel.errorText, button: "ОК", button2: nil) {
                        viewModel.isActiveElement.toggle()
                        viewModel.errorOccured.toggle()
                    } action2: { }
                } else {
                    NotificationView(text: viewModel.errorText, button: "Продолжить", button2: "Отменить") {
                        viewModel.inActiveElement(to: viewModel.card, element: viewModel.element)
                        viewModel.errorOccured.toggle()
                    } action2: {
                        viewModel.isActiveElement.toggle()
                        viewModel.errorOccured.toggle()
                    }
                }
            }
        }
        .onChange(of: viewModel.name) { newValue in
            viewModel.isChangeElement = true
        }
        .onChange(of: viewModel.label) { newValue in
            viewModel.isChangeElement = true
        }
    }
}
