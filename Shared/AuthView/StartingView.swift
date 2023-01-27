//
//  StartingView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct StartingView: View {
    @ObservedObject var viewModel: AuthViewModel
    private var name: String {
        viewModel.name
    }
    private var surname: String {
        viewModel.surname
    }
    private var image: UIImage? {
       UIImage(data: viewModel.imageData)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            CircleAvatarView(image: image, disable: true) {
                do {}
            }
            
            Text("Здравствуйте, \(name) \(surname)!")
                .font(.body)
                .lineLimit(2)
                .minimumScaleFactor(scaleFactor)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 10)

            VStack {
                CustomButton(text: "Продолжить") {
                    viewModel.isFinish.toggle()
                }
                HorizontalDividerLabelView(label: "или")
                HStack(alignment: .center, spacing: 20) {
                    TextButton(text: "Сменить пользователя") {
                        viewModel.isExit.toggle()
                    }
                    TextButton(text: "Редактировать профиль") {
                        viewModel.showView = .edit
                    }
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
    }
}

