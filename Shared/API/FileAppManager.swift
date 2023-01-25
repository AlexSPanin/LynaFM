//
//  FileAppManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//

import Foundation


enum DirectoryType: Codable {
    case doc, temp
    var url: URL? {
        switch self {
        case .doc:
            return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        case .temp:
            return fileManager.temporaryDirectory
        }
    }
}

class FileAppManager {
    
    static let shared = FileAppManager()
    private init() {}
    
    // проверяем содержание директории в зависимости от ее типа
    func checkDirectory(to type: DirectoryType) -> [String]? {
        if let directory = type.url {
   //         print("Check Diretory: \(directory)")
            do {
                let filesInDirectory = try fileManager.contentsOfDirectory(atPath: directory.path)
                return filesInDirectory
            } catch {
                return nil
            }
        }
        return nil
    }
    
    // удаляем файл в директории определенной ее ттипом
    func deleteFileProject(to file: String, type: DirectoryType) {
        if let directory = type.url {
            let url = directory.appendingPathComponent(file)
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("ERROR Delete File")
            }
        }
    }
    // удаляем файл по URL
    func deleteFileUrl(_ url: URL) {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            print("ERROR Delete File")
        }
    }
    
    // загружаем и декодируем файл из директории определенного типа
    func loadFile<T: Decodable>(to name: String, type: DirectoryType, model: T.Type, complition: @escaping(Result<T, NetworkError>) -> Void) {
        if let directory = type.url {
            let url = directory.appendingPathComponent(name)
            do {
                let data = fileManager.contents(atPath: url.path)
                if let data = data {
                    let decoder = try JSONDecoder().decode(T.self, from: data)
                    complition(.success(decoder))
                } else {
                    print("ERROR: decoder file from file manager")
                    complition(.failure(.decodeFile))
                }
            } catch {
                print("ERROR: load File from file manager")
                complition(.failure(.loadFile))
            }
        }
    }
    
    // загружаем файл из директории определенной ее видом и возвращаем DATA
    func loadFileData(to name: String, type: DirectoryType, complition: @escaping(Result<Data, NetworkError>) -> Void) {
        if let directory = type.url {
            let url = directory.appendingPathComponent(name)
            do {
                let data = fileManager.contents(atPath: url.path)
                if let data = data {
                    complition(.success(data))
                } else {
                    print("ERROR: load File from file manager NO DATA \(name)")
                    complition(.failure(.loadFile))
                }
            }
        }
    }
    
    // кодирование и сохранение файла в директории с определенным видом
    func saveFile<T: Encodable>(to name: String?, type: DirectoryType, model: T.Type, file: Any) {
        if let directory = type.url, let name = name, let file = file as? T {
 //           print("Save to Diretory: \(directory)")
            let url = directory.appendingPathComponent(name)
            do {
                    let data = try JSONEncoder().encode(file)
                    try data.write(to: url)
            } catch {
                print("ERROR: Save File to File Manager")
            }
        }
    }
    
    // сохранение DATA файла в директории с определенным видом
    func saveFileData (to name: String, type: DirectoryType, data: Data) {
        if let directory = type.url {
            let url = directory.appendingPathComponent(name)
            do {
                try data.write(to: url)
            } catch {
                print("ERROR: Save File to File Manager")
            }
        }
    }
    
    
    
    // MARK: - создаем директорию в основной директории определенную типом
    // MARK: - ВНИМАНИЕ тогда остальные методы надо переделать под суб директории
    func createDirectory(to name: String, type: DirectoryType) {
        if let dirURL = type.url {
            let dataPath = dirURL.appendingPathComponent(name)
            if !FileManager.default.fileExists(atPath: dataPath.path) {
                do {
                    try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

