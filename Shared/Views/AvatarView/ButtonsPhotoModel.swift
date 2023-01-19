//
//  ButtonsPhotoModel.swift
//  AvatarPhotoSwiftUI
//
//  Created by Александр Панин on 31.03.2022.
//

import Foundation

enum ButtonsPhoto: Int {
    case getLibrary, getCamera, savePhoto, rotatedRigth, rotatedLeft
}

struct ButtonsPhotoModel: Hashable {
    var type: ButtonsPhoto
    var nameImage: String
}
