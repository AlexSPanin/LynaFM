//
//  UploadType.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 16.02.2023.
//
//MARK: - ссылки на директории скачивания в FB
import Foundation
import FirebaseStorage

enum UploadType: String {
    case system = "/system/"
    case user = "/user/"
    
    case product = "/product/"
    case product_image = "/product/image/"
    case product_process = "/product/process/"
    case product_data = "/product/data/"
    
    case material = "/material/"
    case material_data = "/material/data/"
    case material_image = "/material/image/"
    
    case bundle = "/bundle/"
    
    case group = "/group/"
    case parameter = "/parameter/"
    case stage = "/stage/"
    
    case order = "/order/"
    
    var filePath: StorageReference {
        return Storage.storage().reference(withPath: self.rawValue)
    }
}
