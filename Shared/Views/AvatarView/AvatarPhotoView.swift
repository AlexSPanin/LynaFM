//
//  AvatarPhotoView.swift
//  AvatarPhotoSwiftUI
//
//  Created by Александр Панин on 31.03.2022.
//

import SwiftUI

struct AvatarPhotoView: View {
    
    @StateObject var viewModel = AvatarPhotoViewModel()
    
    @Binding var imageData: Data
    @Binding var showAvatarPhotoView: Bool
    
    init(imageData: Binding<Data>, showAvatarPhotoView: Binding<Bool>){
        self._imageData = imageData
        self._showAvatarPhotoView = showAvatarPhotoView
    }
    
    var body: some View {
        VStack {            
            HStack{
                Button {
                    showAvatarPhotoView.toggle()
                } label: {
                    Text("Отмена")
                        .foregroundColor(.orange).opacity(0.8)
                }
                Spacer()
                Button {
                    imageData = viewModel.savePhoto()
                    showAvatarPhotoView.toggle()
                } label: {
                    Text("Добавить")
                        .foregroundColor(.cyan).opacity(0.8)
                }
            }
            .font(.body)
            .padding(.horizontal, hPadding)
            .padding(.top, hPadding)
            
            Spacer()
            
            UpperButtonsPhotoView(viewModel: viewModel)
            
            ScrollPhotoView(viewModel: viewModel)
            if viewModel.photo != nil {
                LowerButtonsPhotoView(viewModel: viewModel)
            }
            Spacer()
        }
        .onAppear{
            viewModel.photo = UIImage(data: imageData)
        }
    }
}

