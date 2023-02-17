//
//  CreatedParameterView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 13.02.2023.
//

import SwiftUI

struct CreatedParameterView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: ParameterAdminViewModel
    let isEditing: Bool
    var isDisable: Bool {
        editMode?.wrappedValue == .active || viewModel.type == "Не выбран" || viewModel.name.isEmpty
    }
    
    var body: some View {
        ZStack {
            TopLabelButtonView(label: viewModel.label) {
                if isEditing {
                    viewModel.showEdit.toggle()
                } else {
                    viewModel.showAdd.toggle()
                }
            }
            VStack {
                VStack {
                    TopCardView(isActive: $viewModel.isActive,
                                date: viewModel.date,
                                user: viewModel.nameUser,
                                isEditing: isEditing)
                    
                    HStack {
                        Text("Тип параметра:")
                            .font(.body)
                            .lineLimit(1)
                            .minimumScaleFactor(scaleFactor)
                            .foregroundColor(.accentColor)
                        
                        Menu {
                            ForEach(TypeField.allCases.sorted(by: {$0.label < $1.label}), id: \.self) { type in
                                Button {
                                    viewModel.type = type.label
                                } label: {
                                    Text("\(type.label)")
                                        .font(.body)
                                        .foregroundColor(type.label == viewModel.type ? .cyan.opacity(0.8) : .accentColor)
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(viewModel.type)")
                                    .font(.body)
                                Image(systemName: "tag.circle")
                            }
                            .foregroundColor( viewModel.type != "Не выбран" ? .cyan.opacity(0.8) : .accentColor)
                        }
                        Spacer()
                    }
                    
                    
                    TextFieldView(subtitle: "Наименование",
                                  tipeTextField: .simple, text: $viewModel.name)
                    TextFieldView(subtitle: "Примечание",
                                  tipeTextField: .simple, text: $viewModel.description)
                }
                
                
                if !viewModel.cards.isEmpty, viewModel.card != nil {
                    HStack {
                        Text("Справочник элементов параметра")
                            .frame(width: WIDTH * 0.9, alignment: .leading)
                            .font(.body)
                            .lineLimit(1)
                            .minimumScaleFactor(scaleFactor)
                        Spacer()
                    }
                    .foregroundColor(.accentColor)
                    .padding(.top, hPadding)
                    
                    ParameterElementTabView(viewModel: viewModel)
                }
                Spacer()
                CustomButton(text: "Сохранить", width: WIDTH * 0.4) {
                    if isEditing {
                        viewModel.isEdit.toggle()
                    } else {
                        if viewModel.isEmptyElements {
                            viewModel.isAdd.toggle()
                        } else {
                            viewModel.showAdd.toggle()
                        }
                    }
                }
                .disabled(isDisable)
                .opacity(isDisable ? 0 : 1)
                
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
            .padding(.top, 60)
            .padding(.horizontal, hPadding)
            .padding(.bottom, hPadding)
            
            if viewModel.errorOccured {
                if !viewModel.typeNote {
                    NotificationView(text: viewModel.errorText, button: "ОК", button2: nil) {
                        viewModel.isActive.toggle()
                        viewModel.errorOccured.toggle()
                    } action2: { }
                } else {
                    NotificationView(text: viewModel.errorText, button: "Продолжить", button2: "Отменить") {
                        viewModel.inActive(to: viewModel.card)
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
