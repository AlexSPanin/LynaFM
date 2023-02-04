//
//  CreteUserView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import SwiftUI

struct CreteUserView: View {
    @ObservedObject var viewModel: AuthViewModel
    private var image: UIImage? {
        UIImage(data: viewModel.userAPP.image)
    }
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Заполните свой профиль")
                .font(.body)
                .lineLimit(1)
                .minimumScaleFactor(scaleFactor)
                .multilineTextAlignment(.leading)
            CircleAvatarView(image: image, disable: false) {
                viewModel.showAvatarPhotoView.toggle()
            }
            TextFieldView(subtitle: "Имя",
                          tipeTextField: .userName, text: $viewModel.userAPP.name)
            TextFieldView(subtitle: "Фамилия",
                          tipeTextField: .userName, text: $viewModel.userAPP.surname)
            TextFieldView(subtitle: "Телефон",
                          tipeTextField: .userName, text: $viewModel.userAPP.phone)
            
            VStack {
                CustomButton(text: "Сохранить", width: WIDTH * 0.4) {
                    viewModel.isCreate.toggle()
                }
                HorizontalDividerLabelView(label: "или")
                TextButton(text: "Закрыть") {
                    viewModel.showView = .auth
                }
            }
            .padding(.top, hPadding)
        }
        .padding(.all, hPadding)
        .frame(width: WIDTH * 0.95)
        .background(
            Color.accentColor.opacity(0.1).cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor, lineWidth: 1)
                )
        )
        .sheet(isPresented: $viewModel.showAvatarPhotoView) {
            AvatarPhotoView(imageData: $viewModel.userAPP.image, showAvatarPhotoView: $viewModel.showAvatarPhotoView)
        }
    }
}

