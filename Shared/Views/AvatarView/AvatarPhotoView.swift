//
//  AvatarPhotoView.swift
//  AvatarPhotoSwiftUI
//
//  Created by Александр Панин on 31.03.2022.
//

import SwiftUI

struct AvatarPhotoView: View {
    
    @StateObject var viewModel = AvatarPhotoViewModel()
    @Binding var isChange: Bool
    @Binding var image: Data?
    @Binding var showAvatarPhotoView: Bool
    let size: CGSize
    let filter: Bool
    
    init(imageData: Binding<Data?>, isChange: Binding<Bool>, showAvatarPhotoView: Binding<Bool>, size: CGSize, filter: Bool){
        self._isChange = isChange
        self._image = imageData
        self._showAvatarPhotoView = showAvatarPhotoView
        self.size = size
        self.filter = filter
    }
    
    var body: some View {
        VStack(spacing: hPadding) {
            HStack{
                Button {
                    isChange = false
                    showAvatarPhotoView.toggle()
                } label: {
                    Text(TypeMessage.back.label)
                        .foregroundColor(mainBack)
                }
                Spacer()
                Button {
                    image = viewModel.savePhoto()
                    isChange = true
                    showAvatarPhotoView.toggle()
                } label: {
                    Text(TypeMessage.add.label)
                        .foregroundColor(mainRigth)
                }
            }
            .font(fontN)
            .padding(.horizontal, hPadding)
            .padding(.top, hPadding)

            UpperButtonsPhotoView(viewModel: viewModel)
            
            ScrollPhotoView(viewModel: viewModel, filter: filter, scrollSize: size)
            if viewModel.photo != nil {
                LowerButtonsPhotoView(viewModel: viewModel)
            }
            Spacer()
        }
        .onAppear{
            if let image = image {
                viewModel.photo = UIImage(data: image)
            }
        }
    }
}


