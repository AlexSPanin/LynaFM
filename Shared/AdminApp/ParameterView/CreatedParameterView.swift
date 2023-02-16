//
//  CreatedParameterView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 13.02.2023.
//

import SwiftUI

struct CreatedParameterView: View {
    @ObservedObject var viewModel: ParameterAdminViewModel
    let isEditing: Bool
    var body: some View {
        ZStack {
            TopLabelButtonView(label: viewModel.label) {
                if isEditing {
                    viewModel.showEdit.toggle()
                } else {
                    viewModel.showAdd.toggle()
                }
            }
            ScrollView(.vertical, showsIndicators: true) {
                
                VStack {
                    VStack (spacing: 5) {
                        Text("Дата: \(viewModel.date)")
                            .frame(width: WIDTH * 0.9, alignment: .leading)
                            .font(.body)
                            .lineLimit(1)
                            .minimumScaleFactor(scaleFactor)
                        Text("Ответственный: \(viewModel.nameUser)")
                            .frame(width: WIDTH * 0.9, alignment: .leading)
                            .font(.body)
                            .lineLimit(1)
                            .minimumScaleFactor(scaleFactor)
                    }
                    .foregroundColor(.accentColor)
                    .padding(.top, hPadding)
                    
                    
                    
                    Toggle(isOn: $viewModel.isActive) {
                        Text(viewModel.isActive ? "Активировано" : "Архив")
                            .font(.body)
                            .lineLimit(1)
                            .minimumScaleFactor(scaleFactor)
                            .foregroundColor(viewModel.isActive ? .cyan.opacity(0.8) : .orange.opacity(0.8))
                    }
                    .disabled(!isEditing)
                    .padding(.horizontal, hPadding)
                    // добавить признак активности
                    VStack {
                        TextFieldView(subtitle: "Наименование",
                                      tipeTextField: .simple, text: $viewModel.name)
                        TextEditorView(subtitle: "Примечание", height: HEIGHT * 0.3, text: $viewModel.label)
                        
                        VStack {
                            CustomButton(text: "Сохранить", width: WIDTH * 0.4) {
                                if isEditing {
                                    viewModel.isEdit.toggle()
                                } else {
                                    viewModel.isAdd.toggle()
                                }
                            }
                            HorizontalDividerLabelView(label: "или")
                            TextButton(text: "Закрыть") {
                                if isEditing {
                                    viewModel.showEdit.toggle()
                                } else {
                                    viewModel.showAdd.toggle()
                                }
                            }
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
                        viewModel.isActive.toggle()
                        viewModel.errorOccured.toggle()
                    } action2: { }
                } else {
                    NotificationView(text: viewModel.errorText, button: "Продолжить", button2: "Отменить") {
                        viewModel.inActive(to: viewModel.card!, element: viewModel.element)
                        viewModel.errorOccured.toggle()
                    } action2: {
                        viewModel.isActive.toggle()
                        viewModel.errorOccured.toggle()
                    }
                }
            }
        }
        .onChange(of: viewModel.name) { newValue in
            viewModel.isChange = true
        }
        .onChange(of: viewModel.label) { newValue in
            viewModel.isChange = true
        }
        
        
        
    }
}
