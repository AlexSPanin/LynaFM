//
//  AvatarPhotoViewModel.swift
//  AvatarPhotoSwiftUI
//
//  Created by Александр Панин on 31.03.2022.
//
import SwiftUI

class AvatarPhotoViewModel: ObservableObject {
    
    let upperButtons = ButtonsPhotoDataManager.getUpperButtonsPhoto()
    let lowerButtons = ButtonsPhotoDataManager.getLowerButtonsPhoto()
    
    var typePressButton: ButtonsPhoto = .getLibrary
    {
        didSet
        { pressedButtonsPhoto() }
    }
    
    @Published var isChange = false
    
    @Published var photo: UIImage?
    
    @Published var frameCGRect = CGRect.zero
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var isImagePickerDisplay = false
    
    @Published var colorButton = Color.accentColor
    @Published var sizeButton: CGFloat = WIDTH * 0.1
    
  //  @Published var didEditUserImage: Bool = false
    
    init() {
     //   fethPhoto()
    }
    
//    func fethPhoto() {
//        let dataImage = StorageManager.shared.fetchData()
//        if let photo = UIImage(data: dataImage, scale: 1.0) { self.photo = photo }
//    }
    
    func pressedButtonsPhoto() {
        switch typePressButton {
        case .getLibrary:
            self.sourceType = .photoLibrary
            self.isImagePickerDisplay.toggle()
        case .getCamera:
            self.sourceType = .camera
            self.isImagePickerDisplay.toggle()
        case .savePhoto:
            do {}
     //       savePhoto()
            
        case .rotatedRigth:
            guard let photo = photo else { return }
            let rotatedImage = photo.rotate(radians: .pi * 0.5)
            self.photo = rotatedImage
            self.isChange = true
        case .rotatedLeft:
            guard let photo = photo else { return }
            let rotatedImage = photo.rotate(radians: .pi * 1.5)
            self.photo = rotatedImage
            self.isChange = true
        }
    }
    
    func savePhoto() -> Data {
       var imageData = Data()
        guard var photo = photo else { return Data() }
        let cgRect = frameCGRect
        
        let orientation = photo.imageOrientation
        let scale = photo.scale
        let cgImage = photo.cgImage
       
        if let cropperCGImage = cgImage?.cropping(to: cgRect) {
            let context = CIContext(options: nil)
            let ciImage = CIImage(cgImage: cropperCGImage)
            if let refImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let uiImage = UIImage(cgImage: refImage, scale: scale, orientation: orientation)
                photo = uiImage
            }
        }
        if let dataImage = photo.jpegData(compressionQuality: 0.5) {
            imageData = dataImage
            //  StorageManager.shared.save(at: dataImage)
//            NetworkManager.shared.editUserImage(imageData: dataImage) {result in
//                switch result {
//                case .success(_):
//                    self.didEditUserImage = true
//                case .failure(_):
//                    do {}
//                }
//            }
        }
        self.photo = photo
        self.isChange = true
        self.frameCGRect = CGRect(origin: CGPoint.zero, size: photo.size)
        
        return imageData
    }
    
    // MARK: - применение фильтра и вывод изображения во вью
    func imageFilter(_ photo: UIImage) -> UIImage {
        var photo = photo
        let context = CIContext(options: nil)
        let inputImage = CIImage(image: photo)
        let currentFilter = CIFilter(name: "CIPhotoEffectMono")
        currentFilter?.setDefaults()
        currentFilter?.setValue(inputImage, forKey: kCIInputImageKey) // ключ определяет определяет входное изображение
        if let output = currentFilter?.outputImage {
            if let cgImage = context.createCGImage(output, from: output.extent) {
                photo = UIImage(cgImage: cgImage)
            }
        }
        return photo
    }
}