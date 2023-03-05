//
//  CreteUserView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import SwiftUI

struct EditProfileUserView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var name = ""
    @State private var surname = ""
    @State private var phone = ""
    @State private var isChange = false
    private let size = CGSize(width: WIDTH, height: WIDTH)
    var body: some View {
        ZStack {
        VStack(alignment: .center, spacing: 10) {
            Text("Отредактируйте свой профиль")
                .font(fontN)
                .lineLimit(1)
                .minimumScaleFactor(scale)
                .multilineTextAlignment(.leading)
            CircleAvatarView(image: viewModel.photo, disable: false) {
                viewModel.showFolder.toggle()
            }
            TextFieldView(subtitle: "Имя",
                          tipeTextField: .userName, text: $name)
            TextFieldView(subtitle: "Фамилия",
                          tipeTextField: .userName, text: $surname)
            TextFieldView(subtitle: "Телефон",
                          tipeTextField: .userName, text: $phone)
        }
        .padding(.all, hPadding)
        .frame(width: WIDTH * 0.95)
        .background(
            Color.accentColor.opacity(0.1).cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor, lineWidth: 1)
                )
        )
            ReturnAndSaveButton(disableSave: false,
                                disableBack: false) {
                viewModel.isEdit.toggle()
            } actionBack: {
                viewModel.showView = .starting
            }
            .padding(.top, hPadding)
        }
        .sheet(isPresented: $viewModel.showFolder) {
            AvatarPhotoView(imageData: $viewModel.photo,
                            isChange: $isChange,
                            showAvatarPhotoView: $viewModel.showFolder,
                            size: size, filter: true)
        }
        .onChange(of: isChange) { newValue in
            if newValue {
                viewModel.isChange = true
            }
        }
        .onChange(of: name) { newValue in
                viewModel.currentUser?.name = newValue
                viewModel.isChange = true
        }
        .onChange(of: surname) { newValue in
                viewModel.currentUser?.surname = newValue
                viewModel.isChange = true
        }
        .onChange(of: phone) { newValue in
                viewModel.currentUser?.phone = newValue
                viewModel.isChange = true
        }
        .onAppear {
            if let card = viewModel.currentUser {
                name = card.name
                surname = card.surname
                phone = card.phone
            }
        }
    }
}

