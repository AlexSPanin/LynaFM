//
//  ProfileUserView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct ProfileUserView: View {
    @ObservedObject var viewModel: AuthViewModel
    private var image: UIImage? {
       UIImage(data: viewModel.image)
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
  //          AvatarPhotoView(imageData: $viewModel.image, showAvatarPhotoView: $viewModel.showAvatarPhotoView)
            
            TextFieldView(subtitle: "Имя",
                          tipeTextField: .userName, text: $viewModel.name)
            TextFieldView(subtitle: "Фамилия",
                          tipeTextField: .userName, text: $viewModel.surname)
            TextFieldView(subtitle: "Телефон",
                          tipeTextField: .userName, text: $viewModel.phone)
            
            VStack {
                CustomButton(text: "Сохранить") {
                    viewModel.isEdit.toggle()
                }
                HorizontalDividerLabelView(label: "или")
                TextButton(text: "Закрыть") {
                    viewModel.showView = .auth
                }
            }
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
            AvatarPhotoView(imageData: $viewModel.image, showAvatarPhotoView: $viewModel.showAvatarPhotoView)
        }
    }
}
