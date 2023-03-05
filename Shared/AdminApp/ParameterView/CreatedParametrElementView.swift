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
    @State private var isChange = false
    let isEditing: Bool
    var isImage: Bool {
        viewModel.image != nil
    }
    
    var isColor: Bool {
        viewModel.type == "Цвет"
    }
    var subtitle: String {
        switch viewModel.type {
        case TypeField.number.label:
            return "Добавьте Коэф. пересчета"
        case TypeField.color.label:
            return "Добавьте Цвет: FFFFFFFF"
        case TypeField.text.label:
            return "Добавьте Описание"
        default:
            return "Добавьте Параметр"
        }
    }
    
    var isDisable: Bool {
        viewModel.description.isEmpty || viewModel.name.isEmpty
    }
    
    var uiImage: UIImage {
        if let image = viewModel.image, let ui = UIImage(data: image) {
            return ui
        } else {
            return UIImage()
        }
    }
    private let size = CGSize(width: WIDTH, height: WIDTH * 3 / 4)
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
                            if isColor {
                                Spacer()
                            }
                            
                            ZStack {
                            Button {
                                showFolder.toggle()
                            } label: {
                                if isImage {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .interpolation(.medium)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: WIDTH * 0.3, height: WIDTH * 0.3)
                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                } else {
                                    Text(isColor ? "Загрузить текстуру." : "Загрузить изображение.")
                                        .font(.callout)
                                        .foregroundColor(.accentColor)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .minimumScaleFactor(0.9)
                                        .frame(width: WIDTH * 0.3, height: WIDTH * 0.3)
                                }
                            }
                                Button {
                                    viewModel.isDeleteImage.toggle()
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.accentColor)
                                        .padding(.all, 3)
                                        .background(
                                            Circle().foregroundColor(.white)
                                        )
                                }
                                .offset(x: WIDTH * 0.1 , y: -WIDTH * 0.1)

                            }
                            .frame(width: WIDTH * 0.3, height: WIDTH * 0.3, alignment: .center)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 1))

                            Spacer()

                        }
                        
                        if isColor {
                                ColorPicker(selection: $viewModel.color, supportsOpacity: true) {
                                    Text("Выбрать цвет вручную:")
                                        .font(.callout)
                                        .foregroundColor(.accentColor)
                                }
                                .disabled(isImage)
                                .opacity(isImage ? 0.3 : 1)
                        }
                        
                        TextFieldView(subtitle: "Наименование",
                                      tipeTextField: .simple, text: $viewModel.name)
                        
                        TextFieldView(subtitle: subtitle,
                                      tipeTextField: .simple, text: $viewModel.description)
                        .disabled(isColor)
                        .opacity(isColor ? 0.3 : 1)
                        
                        ReturnAndSaveButton(disableSave: isDisable,
                                            disableBack: false) {
                            if isEditing {
                                viewModel.isEditElement.toggle()
                            } else {
                                viewModel.isAddElement.toggle()
                            }
                        } actionBack: {
                            if isEditing {
                                viewModel.showEditElement.toggle()
                            } else {
                                viewModel.showAddElement.toggle()
                            }
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
                    NotificationView(text: viewModel.errorText,
                                     button: TypeMessage.enter.label,
                                     button2: TypeMessage.back.label) {
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
        .onChange(of: viewModel.description) { newValue in
            viewModel.isChangeElement = true
        }
        .onChange(of: viewModel.image) { newValue in
            viewModel.isChangeElement = true
        }
        .onChange(of: viewModel.color, perform: { newValue in
            viewModel.description = newValue.hexDescription()
        })
        .sheet(isPresented: $showFolder) {
            AvatarPhotoView(imageData: $viewModel.image,
                            isChange: $isChange,
                            showAvatarPhotoView: $showFolder,
                            size: size, filter: false)
        }
    }
}
