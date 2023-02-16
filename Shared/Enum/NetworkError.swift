//
//  NetworkError.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 16.02.2023.
//

//MARK: -  сетевые ошибки
import Foundation

enum NetworkError: Error {
    case fetchVersion
    case fetchUser
    case fetchCollection
    case fetchElement
    
    case loadFile
    case loadStorage
    
    case decodeCollection
    case decodeStorage
    case decodeFile
}
