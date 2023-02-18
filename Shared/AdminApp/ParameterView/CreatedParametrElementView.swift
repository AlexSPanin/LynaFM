//
//  CreatedParametrElementView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 16.02.2023.
//

import SwiftUI

struct CreatedParametrElementView: View {
    @ObservedObject var viewModel: ParameterAdminViewModel
    @State private var showFolder = false
    @State private var image = UIImage()
    let isEditing: Bool
    var isImage: Bool {
        if let card = viewModel.card, let element = viewModel.element {
            return !viewModel.cards[card].elements[element].images.isEmpty
        } else {
            return false
        }
    }
    var subtitle: String {
        switch viewModel.type {
        case TypeField.number.label:
            return "Коэф. пересчета"
        case TypeField.color.label:
            return "Цвет: #FFFFFFFF"
        case TypeField.text.label:
            return "Описание"
        default:
            return "Параметр"
        }
    }
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
                        
                        // загрузка файла изображения
                        HStack {
                            Button {
                                showFolder.toggle()
                            } label: {
                                if isImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .interpolation(.medium)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: WIDTH * 0.3, height: WIDTH * 0.3)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                } else {
                                    Text("Загрузить изображение.")
                                        .font(.callout)
                                        .foregroundColor(.accentColor)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .minimumScaleFactor(0.9)
                                        .frame(width: WIDTH * 0.3, height: WIDTH * 0.3)
                                }
                            }
                            .frame(width: WIDTH * 0.3, height: WIDTH * 0.3, alignment: .center)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 1))
                            .fileImporter(isPresented: $showFolder, allowedContentTypes: [.item], allowsMultipleSelection: false, onCompletion: { results in
                                switch results {
                                case .success(let fileurl):
                                    if let url = fileurl.first {
                                        if url.startAccessingSecurityScopedResource() {
                                            print(url)
                                            image = viewModel.loadFileImage(to: url)
                                        }
                                    }
                                case .failure(let error):
                                    print(error)
                                }
                            })
                            Spacer()
                        }
                        
                        TextFieldView(subtitle: "Наименование",
                                      tipeTextField: .simple, text: $viewModel.name)
                        TextFieldView(subtitle: subtitle,
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
                }
            }
            .padding(.top, 60)
            .padding(.horizontal, hPadding)
            .padding(.bottom, hPadding)
            
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
