//
//  CreatedGroupView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.02.2023.
//

import SwiftUI

struct CreatedGroupView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: GroupAdminViewModel
    @State private var showFolder = false
    @State private var isChange = false
   
    let isEditing: Bool
    var isImage: Bool {
        viewModel.image != nil
    }
    var uiImage: UIImage {
        if let image = viewModel.image, let ui = UIImage(data: image) {
            return ui
        } else {
            return UIImage()
        }
    }
    var isDisable: Bool {
        editMode?.wrappedValue == .active || viewModel.type == "" || viewModel.name.isEmpty
    }
    private let size = CGSize(width: WIDTH, height: WIDTH * 3 / 4)
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
                    
                    // загрузка файла изображения
                    HStack {
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
                                Text("Загрузить изображение.")
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
                    
                    
                    HStack {
                        Text("Тип товарной группы:")
                            .font(.body)
                            .lineLimit(1)
                            .minimumScaleFactor(scale)
                            .foregroundColor(.accentColor)
                        
                        Menu {
                            ForEach(TypeGroup.allCases.sorted(by: {$0.label < $1.label}), id: \.self) { type in
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
                                Image(systemName: "plus.circle")
                                    .opacity(isEditing ? 0 : 1)
                            }
                            .foregroundColor( viewModel.type != "" ? .cyan.opacity(0.8) : .accentColor)
                        }
                        Spacer()
                    }
                    .disabled(isEditing)
                    
                    
                    TextFieldView(subtitle: "Наименование",
                                  tipeTextField: .simple, text: $viewModel.name)
                    TextFieldView(subtitle: "Примечание",
                                  tipeTextField: .simple, text: $viewModel.description)
                }
                
                Spacer()
                
                ReturnAndSaveButton(disableSave: isDisable,
                                    disableBack: editMode?.wrappedValue == .active) {
                    if isEditing {
                        viewModel.isEdit.toggle()
                    } else {
                        viewModel.isAdd.toggle()
                    }
                } actionBack: {
                    if isEditing {
                        viewModel.showEdit.toggle()
                    } else {
                        viewModel.showAdd.toggle()
                    }
                }
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
                        viewModel.inActive(to: viewModel.index)
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
        .onChange(of: viewModel.description) { newValue in
            viewModel.isChange = true
        }
        .onChange(of: viewModel.image) { newValue in
            viewModel.isChange = true
        }
        .sheet(isPresented: $showFolder) {
            AvatarPhotoView(imageData: $viewModel.image,
                            isChange: $isChange,
                            showAvatarPhotoView: $showFolder,
                            size: size, filter: false)
        }
    }
}
