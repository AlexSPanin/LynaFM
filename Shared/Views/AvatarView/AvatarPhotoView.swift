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
        ZStack{
            Color.white
            VStack {
                
                HStack{
                    Button {
                        showAvatarPhotoView.toggle()
                    } label: {
                        Text("Отмена")
                    }
                    Spacer()
                    Button {
                        imageData = viewModel.savePhoto()
                        showAvatarPhotoView.toggle()
                    } label: {
                        Text("Ок")
                    }
                }
                .font(.title3)
                .foregroundColor(.gray)
                .padding()
                
                Spacer()
                UpperButtonsPhotoView(viewModel: viewModel)
                
                ScrollPhotoView(viewModel: viewModel)
                if viewModel.photo != nil {
                    LowerButtonsPhotoView(viewModel: viewModel)
                }
                Spacer()
            }
        }
    }
}

