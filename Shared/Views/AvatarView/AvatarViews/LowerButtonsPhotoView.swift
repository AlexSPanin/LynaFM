//
//  LowerButtonsPhotoView.swift
//  AvatarPhotoSwiftUI
//
//  Created by Александр Панин on 31.03.2022.
//

import SwiftUI

struct LowerButtonsPhotoView: View {
    @ObservedObject var viewModel: AvatarPhotoViewModel
    var body: some View {
        HStack(spacing: 150) {
            ForEach(viewModel.lowerButtons, id: \.self) { button in
                Button {
                    viewModel.typePressButton = button.type
                } label: {
                    Image(systemName: button.nameImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: viewModel.sizeButton, height: viewModel.sizeButton)
                        .foregroundColor(viewModel.colorButton)
                }
            }
        } .padding(2)
    }
}
