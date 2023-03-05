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
    let filter: Bool
    let scrollSize: CGSize
    
    var body: some View {
        VStack {
            Divider()
                .frame(width: screen * 0.9, height: 1, alignment: .center)
            ZStack {
                if viewModel.photo != nil {
                    ImageScrollView(viewModel: viewModel, scrollSize: scrollSize)
                } else {
                    Image(systemName: "camera.viewfinder")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageS, height: imageS)
                        .foregroundColor(viewModel.colorButton)
                }
            }
            .frame(width: scrollSize.width, height: scrollSize.height)
            .background(Color.white)
            
            Divider()
                .frame(width: screen * 0.9, height: 1, alignment: .center)
        }
        .sheet(isPresented: $viewModel.isImagePickerDisplay, onDismiss: chagePhoto) {
            ImagePickerView(selectedImage: self.$selectedImage, sourceType: viewModel.sourceType)
        }
    }
}

extension ScrollPhotoView {
    private func chagePhoto() {
        guard let image = selectedImage else { return }
        if filter {
            viewModel.photo = viewModel.imageFilter(image)
        } else {
            viewModel.photo = image
        }
        viewModel.isChange = true
        viewModel.frameCGRect = CGRect(origin: CGPoint.zero, size: image.size)
    }
}

