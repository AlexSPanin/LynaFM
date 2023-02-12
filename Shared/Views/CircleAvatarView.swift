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
                    .frame(width: WIDTH * 0.3, height: WIDTH * 0.3)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 1))
            }
            .disabled(disable)
        } else {
            ZStack {
                Color.accentColor.opacity(0.1)
                    .frame(width: WIDTH * 0.3, height: WIDTH * 0.3)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 1))
                Button  {
                    action()
                } label: {
                    VStack {
                        Image(systemName: "camera")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: WIDTH * 0.05)
                        Text(disable ? "нет фото" : "Добавьте фото")
                            .font(.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                    .foregroundColor(.accentColor)
                }
                .disabled(disable)
            }
        }
    }
}

