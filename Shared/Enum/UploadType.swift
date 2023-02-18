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
    case temp = "/temp/"
    case data = "/data/"
    case image = "/image/"
    
    var filePath: StorageReference {
        return Storage.storage().reference(withPath: self.rawValue)
    }
}
