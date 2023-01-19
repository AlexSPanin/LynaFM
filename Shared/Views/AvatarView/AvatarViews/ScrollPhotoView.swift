//
//  ScrollPhotoView.swift
//  AvatarPhotoSwiftUI
//
//  Created by Александр Панин on 31.03.2022.
//

import SwiftUI

struct ScrollPhotoView: View {
    
    @ObservedObject var viewModel: AvatarPhotoViewModel
    @State private var selectedImage: UIImage?
    var scrollSize: CGSize {
         CGSize(width: WIDTH * 0.8, height: WIDTH * 0.8)
    }
    
    var body: some View {
        ZStack {
            if viewModel.photo != nil {
                ZStack {
                    ImageScrollView(viewModel: viewModel, scrollSize: scrollSize)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5).stroke( viewModel.colorButton, lineWidth: 2)
                        )
            }
            } else {
                ZStack {
                    Image(systemName: "camera.on.rectangle")
                        .resizable()
                        .frame(width: scrollSize.width/3, height: scrollSize.width/3)
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(viewModel.colorButton)
                }
            }
        }
        .frame(width: scrollSize.width, height: scrollSize.height)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: buttonCorner).stroke( viewModel.colorButton, lineWidth: 2)
        )
        .sheet(isPresented: $viewModel.isImagePickerDisplay, onDismiss: chagePhoto) {
            ImagePickerView(selectedImage: self.$selectedImage, sourceType: viewModel.sourceType)
        }
    }
}

extension ScrollPhotoView {
    private func chagePhoto() {
        guard let image = selectedImage else { return }
        viewModel.photo = viewModel.imageFilter(image)
        viewModel.isChange = true
        viewModel.frameCGRect = CGRect(origin: CGPoint.zero, size: image.size)
    }
}
