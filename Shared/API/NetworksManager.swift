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

enum UploadType: String {
    case system = "/system/"
    case user = "/user/"
    case product = "/product/"
    case material = "/material/"
    case bundle = "/bundle/"
    case group = "/group/"
    case parameter = "/parameter/"
    case stage = "/stage/"
    
    case order = "/order/"
    
    var filePath: StorageReference {
        return Storage.storage().reference(withPath: self.rawValue)
    }
}

// базы данных
enum NetworkCollection: String {
    case system = "system"
    case user = "user"
    case product = "product"
    case material = "material"
    case bundle = "bundle"
    case group = "group"
    case parameter = "parameter"
    case stage = "stage"
    
    case order = "order"
    
    var collection: String {
        return self.rawValue
    }
}

struct SystemApp: Codable {
    var ver = ""
    var user = ""
    var product = ""
    var material = ""
    var bundle = ""
    var group = ""
    var parameter = ""
    var stage = ""
}


class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    //MARK: - методы работы с пользователем USER
    // получаем uid пользователя
    private func getUserUid() -> String {
        if let currentUid = AuthUserManager.shared.userSession?.uid {
            print("Current Uid \(currentUid)")
            return currentUid
        }
        return ""
    }
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
        upLoadElementCollection(to: .user, name: name, data: data)
    }
    // MARK: -  работа с хранилищем загрузка и выгрузка файлов ввиде Data
    // сохранение файла с автоматическим uuid - возвращает путь к файлу
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
                completion(.failure(.loadFile))
            } else {
                guard let dataFile = data else { return }
                completion(.success(dataFile))
            }
        }
    }
    
    // MARK: - работа с коллекцией
    // получить весь список из коллекции ввиде [QueryDocumentSnapshot]
    func fetchFullCollection<T: Decodable>(to collection: NetworkCollection, model: T.Type, comletion: @escaping (Result<[T], NetworkError>) -> Void ) {
        Firestore.firestore().collection(collection.collection).getDocuments { querySnapshot, error in
            if error != nil {
                comletion(.failure(.fetchCollection))
            } else {
                if let documents = querySnapshot?.documents {
                    var datas = [T]()
                    for document in documents {
                        do {
                            let data = try? document.data(as: T.self)
                            if let data = data {
                                datas.append(data)
                            } else {
                                print("ERROR: Decode Network data")
                            }
                        }
                    }
                    comletion(.success(datas))
                } else {
                    comletion(.failure(.fetchCollection))
                }
            }
        }
    }
    
    // получить элемент коллекции DocumentSnapshot
    func fetchElementCollection<T: Decodable>(to collection: NetworkCollection, doc: String, model: T.Type, comletion: @escaping (Result<T, NetworkError>) -> Void ) {
        Firestore.firestore().collection(collection.collection).document(doc).getDocument(as: T.self) {result in
            switch result {
            case .success(let element):
                comletion(.success(element))
            case .failure(_):
                comletion(.failure(.fetchElement))
            }
        }
    }
    
    // записать элемент коллекции [String: Any]
    func upLoadElementCollection(to collection: NetworkCollection, name: String, data: [String : Any]) {
        let collection = collection.collection
        let time = Date().timeStamp()
        let system = NetworkCollection.system.collection
        Firestore.firestore().collection(collection).document(name).setData(data)
        updateValueElement(to: .system, document: system, key: collection, value: time)
    }
    
    // изменить значение поля элемента в коллекции
    func updateValueElement(to collection: NetworkCollection, document: String, key: String, value: Any) {
        let collection = collection.collection
        Firestore.firestore().collection(collection).document(document).updateData([key : value])
    }
}
