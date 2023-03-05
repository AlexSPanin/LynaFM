//
//  LowerButtonsPhotoView.swift
//  AvatarPhotoSwiftUI
//
//  Created by Александр Панин on 31.03.2022.
//

import SwiftUI

struct LowerButtonsPhotoView: View {
    @ObservedObject var viewModel: AvatarPhotoViewModel
    private var spacing: CGFloat {
        let count = viewModel.upperButtons.count
        if count == 1 {
            return 0
        } else {
            let size = viewModel.sizeButton * CGFloat(count)
            return ((screen * 0.8) - size) / CGFloat(count - 1)
        }
    }
    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            ForEach(viewModel.lowerButtons, id: \.self) { button in
                Button {
                    viewModel.typePressButton = button.type
                } label: {
                    Image(systemName: button.nameImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: viewModel.sizeButton)
                        .foregroundColor(viewModel.colorButton)
                }
            }
        }
        .frame(width: screen * 0.8)
    }
}
