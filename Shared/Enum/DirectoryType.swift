//
//  DirectoryType.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 17.02.2023.
//

import Foundation

enum DirectoryType: Codable {
    case doc, temp, assets
    var url: URL? {
        switch self {
        case .doc:
            return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        case .temp:
            return fileManager.temporaryDirectory
        case .assets:
            return fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        }
    }
}
