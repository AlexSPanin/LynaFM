//
//  NetworksManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation
import Firebase
import FirebaseStorage

enum NetworkError: Error {
    case fetchUser
    case fetchVersion
    case decodeUser
    case fetchAllUsers
    case upLoad
    case invalidURL
    
    case downloadURL
    case noData
    case noMetadata
    case decodingError
    case uploadDataError
    case removeFileError
    case loadFileError
    case uploadError
    case userError
    case errorLoadProfile
}

enum UploadType: String {
    case user_data = "/user/data/"
    case user_image = "/user/image/"
    
    var filePath: StorageReference {
        return Storage.storage().reference(withPath: self.rawValue)
    }
}

struct System: Codable {
    var ver = ""
}


class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    // получаем версию программы
    func fetchVersion(completion: @escaping (Result<String, NetworkError>) -> Void) {
        Firestore.firestore().collection("system").document("system").getDocument {document, error in
            if error != nil {
                completion(.failure(.fetchVersion))
            } else {
                if let version = try? document?.data(as: System.self) {
                    completion(.success(version.ver))
                } else {
                    completion(.failure(.fetchVersion))
                }
            }
        }
    }
    
    
    // сохранение файла с автоматическим uuid - возвращает название файла
    func upLoadFile(to name: String? = nil, type: UploadType, data: Data, completion: @escaping (String) -> Void) {
        var uuid = UUID().uuidString
        if let name = name { uuid = name }
        let storageRef = type.filePath.child(uuid)
        storageRef.putData(data, metadata: nil) { _, error in
            if error != nil {
                print("ERROR: upLoad File")
                completion("")
            } else {
                print("FINISH: upLoad File ")
                completion(uuid)
            }
        }
    }
    
    // загрузка файла по названию и типу
    func loadFile(type: UploadType, name: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        
        let storageRef = type.filePath.child(name)
        storageRef.getData(maxSize: 5 * 1024 * 1024 ) { data, error in
            if let error = error {
                print("NetworkManager ERROR: loadFile  type \(type)", error.localizedDescription)
                completion(.failure(.loadFileError))
            } else {
                guard let dataFile = data else { return }
                completion(.success(dataFile))
            }
        }
    }
}


//MARK: - методы работы с пользователем
extension NetworkManager {
    // сохранение пользователя
    func upLoadUser(user: User?, completion: @escaping () -> Void) {
        let name = getUserUid()
        guard let user = user else { return }
        let data = ["date" : user.date,
                    "email" : user.email,
                    "phone" : user.phone,
                    "name" : user.name,
                    "surname" : user.surname,
                    "image" : user.image,
                    "profile" : user.profile,
                    "isActive" : user.isActive
        ] as [String : Any]
        Firestore.firestore().collection("user").document(name).setData(data)
    }
    
    // загрузка пользователя
    func loadUser(name: String, completion: @escaping (Result<User, NetworkError>) -> Void) {
        print("NetworkManager: loadUser: \(name)")
        Firestore.firestore().collection("user").document(name).getDocument { document, error in
            if error != nil {
                print("NetworkManager ERROR: getDocument")
                completion(.failure(.fetchUser))
            }
            if let user = try? document?.data(as: User.self) {
                print("NetworkManager: Пользователь загружен из сети")
                completion(.success(user))
            } else {
                print("NetworkManager ERROR: loadUser try getDocument")
                completion(.failure(.fetchUser))
            }
        }
    }
}

extension NetworkManager {
    // получаем uid пользователя
    private func getUserUid() -> String {
        if let currentUid = AuthUserManager.shared.userSession?.uid {
            print("Current Uid \(currentUid)")
            return currentUid
        }
        return ""
    }
    // получаем полный список пользователей
    func fetchAllUsers(comletion: @escaping (Result<[User], NetworkError>) -> Void ) {
        Firestore.firestore().collection("user").getDocuments { querySnapshot, error in
            if error != nil {
                comletion(.failure(.fetchAllUsers))
            } else {
                if let documents = querySnapshot?.documents {
                    var users = [User]()
                    for document in documents {
                        if let user = try? document.data(as: User.self) {
                            users.append(user)
                        }
                    }
                    comletion(.success(users))
                } else {
                    comletion(.failure(.decodeUser))
                }
            }
        }
    }
}
