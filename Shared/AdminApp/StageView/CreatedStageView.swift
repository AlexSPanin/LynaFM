//
//  EditStageView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 11.02.2023.
//

import SwiftUI

struct CreatedStageView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: StageAdminViewModel
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
                                      tipeTextField: .simple, text: $viewModel.card.name)
                        TextEditorView(subtitle: "Примечание", height: HEIGHT * 0.3, text: $viewModel.card.label)
                        
                        VStack {
                            CustomButton(text: "Сохранить", width: WIDTH * 0.4) {
                                if isEditing {
                                    viewModel.isEdit.toggle()
                                } else {
                                    viewModel.isAdd.toggle()
                                }
                            }
                            .disabled(editMode?.wrappedValue == .active)
                            .opacity(editMode?.wrappedValue == .active ? 0 : 1)
                            
                            HorizontalDividerLabelView(label: "или")
                            
                            TextButton(text: "Закрыть") {
                                if isEditing {
                                    viewModel.showEdit.toggle()
                                } else {
                                    viewModel.showAdd.toggle()
                                }
                            }
                            .foregroundColor(.cyan.opacity(0.8))
                            .disabled(editMode?.wrappedValue == .active)
                            .opacity(editMode?.wrappedValue == .active ? 0 : 1)
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
                        viewModel.inActive()
                        viewModel.errorOccured.toggle()
                    } action2: {
                        viewModel.isActive.toggle()
                        viewModel.errorOccured.toggle()
                    }
                }
            }
        }
        .onChange(of: viewModel.card.name) { newValue in
            viewModel.isChange = true
        }
        .onChange(of: viewModel.card.label) { newValue in
            viewModel.isChange = true
        }
        
        
        
    }
}
