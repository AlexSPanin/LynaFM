//
//  CircleAvatarView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct CircleAvatarView: View {
    let image: Data?
    let disable: Bool
    let action: () -> Void
    private var uiImage: UIImage {
        if let image = image, let ui = UIImage(data: image) {
            return ui
        } else {
            return UIImage()
        }
    }
    
    var body: some View {
        if uiImage != UIImage() {
            Button {
                action()
            } label: {
                Image(uiImage: uiImage)
                    .resizable()
                    .interpolation(.medium)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageL, height: imageL)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(mainColor, lineWidth: 1))
            }
            .disabled(disable)
        } else {
            ZStack {
                mainLigth
                    .frame(width: imageL, height: imageL)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(mainColor, lineWidth: 1))
                Button  {
                    action()
                } label: {
                    VStack {
                        Image(systemName: "camera")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: pickerL)
                        Text(disable ? "нет фото" : "Добавьте фото")
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(scale)
                    }
                    .foregroundColor(mainColor)
                }
                .disabled(disable)
            }
        }
    }
}

