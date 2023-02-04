//
//  NotificationMessage.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import Foundation

enum NotificationMessage: Error {
    case version
    
    var text: String {
        switch self {
            
        case .version:
            return  "Необходимо обновить программу!"
        }
    }
}
