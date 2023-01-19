//
//  ButtonsPhotoDataManager.swift
//  AvatarPhotoSwiftUI
//
//  Created by Александр Панин on 31.03.2022.
//

import Foundation

struct ButtonsPhotoDataManager {
    
    static func getUpperButtonsPhoto() -> [ButtonsPhotoModel] {
      [
        ButtonsPhotoModel(type: .getLibrary, nameImage: "photo"),
        ButtonsPhotoModel(type: .getCamera, nameImage: "camera")
      ]
    }
    
    static func getLowerButtonsPhoto() -> [ButtonsPhotoModel] {
      [
        ButtonsPhotoModel(type: .rotatedLeft, nameImage: "rotate.left"),
      //  ButtonsPhotoModel(type: .savePhoto, nameImage: "square.and.arrow.down"),
        ButtonsPhotoModel(type: .rotatedRigth, nameImage: "rotate.right")
      ]
    }
    private init() {}
}
