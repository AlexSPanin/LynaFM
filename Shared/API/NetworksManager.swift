//
//  NetworksManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift

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
    //MARK: - методы работы с типом продукты
    // сохранение карточки продукты
    func upLoadProduct(to id: String?, product: Product?, completion: @escaping (Bool) -> Void) {
        let collection = NetworkCollection.product.collection
        var idElement = ""
        if let id = id {
            idElement = id
        } else {
            idElement = Firestore.firestore().collection(collection).document().documentID
        }
        if let product = product {
            let data = ["id:" : idElement,
                        "date" : product.date,
                        "idUser" : product.idUser,
                        "idGroup" : product.idGroup,
                        "isActive" : product.isActive,
                        "countUse" : product.countUse,
                        
                        "sort" : product.sort,
                        "article" : product.article,
                        "name" : product.name,
                        "label" : product.label,
                        "file" : product.file,
                        "images" : product.images,
                        "process" : product.process] as [String : Any]
            upLoadElementCollection(to: .product, name: idElement, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }
    //MARK: - методы работы с типом материалы
    // сохранение карточки материалов
    func upLoadMaterial(to id: String?, material: Material?, completion: @escaping (Bool) -> Void) {
        let collection = NetworkCollection.material.collection
        var idElement = ""
        if let id = id {
            idElement = id
        } else {
            idElement = Firestore.firestore().collection(collection).document().documentID
        }
        if let material = material {
        let data = ["id:" : idElement,
                    "date" : material.date,
                    "idUser" : material.idUser,
                    "idGroup" : material.idGroup,
                    "isActive" : material.isActive,
                    "countUse" : material.countUse,
                    
                    "sort" : material.sort,
                    "article" : material.article,
                    "name" : material.name,
                    "label" : material.label,
                    "file" : material.file,
                    "images" : material.images] as [String : Any]
        upLoadElementCollection(to: .material, name: idElement, data: data) { status in
            completion(status)
        }
        } else {
            completion(false)
        }
    }
    //MARK: - методы работы с продуктовой группы
    // сохранение карточки продуктовой группы
    func upLoadGroup(to id: String?, group: Group?, completion: @escaping (Bool) -> Void) {
        let collection = NetworkCollection.group.collection
        var idElement = ""
        if let id = id {
            idElement = id
        } else {
            idElement = Firestore.firestore().collection(collection).document().documentID
        }
        if let group = group {
        let data = ["id:" : idElement,
                    "date" : group.date,
                    "idUser" : group.idUser,
                    "idType" : group.idType,
                    "isActive" : group.isActive,
                    "countUse" : group.countUse,
                    
                    "sort" : group.sort,
                    "name" : group.name,
                    "label" : group.label,
                    "file" : group.file] as [String : Any]
            upLoadElementCollection(to: .group, name: idElement, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }
    //MARK: - методы работы с параметрами товара
    // сохранение карточки параметров товара
    func upLoadParameter(to id: String?, param: ProductParameter?, completion: @escaping (Bool) -> Void) {
        let collection = NetworkCollection.parameter.collection
        var idElement = ""
        if let id = id {
            idElement = id
        } else {
            idElement = Firestore.firestore().collection(collection).document().documentID
        }
        if let param = param {
        let data = ["id:" : idElement,
                    "date" : param.date,
                    "idUser" : param.idUser,
                    "isActive" : param.isActive,
                    "countUse" : param.countUse,
                    
                    "sort" : param.sort,
                    "name" : param.name,
                    "label" : param.label,
                    "file" : param.file] as [String : Any]
            upLoadElementCollection(to: .parameter, name: idElement, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }
    //MARK: - методы работы с этапами производства
    // сохранение этапа производства
    func upLoadStage(to id: String?, stage: ProductionStage?, completion: @escaping (Bool) -> Void) {
        let collection = NetworkCollection.stage.collection
        var idElement = ""
        if let id = id {
            idElement = id
        } else {
            idElement = Firestore.firestore().collection(collection).document().documentID
        }
        if let stage = stage {
        let data = ["id:" : idElement,
                    "date" : stage.date,
                    "idUser" : stage.idUser,
                    "isActive" : stage.isActive,
                    "countUse" : stage.countUse,
                    
                    "sort" : stage.sort,
                    "name" : stage.name,
                    "label" : stage.label] as [String : Any]
            upLoadElementCollection(to: .stage, name: idElement, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }

    //MARK: - методы работы с пользователем USER
    // сохранение пользователя
    func upLoadUser(to id: String?, user: User?, completion: @escaping (Bool) -> Void) {
        var name = AuthUserManager.shared.currentUserID()
        if let id = id {
            name = id
        }
        if let user = user {
        let data = ["id:" : name,
                    "date" : user.date,
                    "email" : user.email,
                    "phone" : user.phone,
                    "name" : user.name,
                    "surname" : user.surname,
                    "image" : user.image,
                    "profile" : user.profile,
                    "isActive" : user.isActive] as [String : Any]
            upLoadElementCollection(to: .user, name: name, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
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
                print("FINISH: upLoad File \(uuid)")
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
                                comletion(.failure(.decodeCollection))
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
    func upLoadElementCollection(to collection: NetworkCollection, name: String, data: [String : Any], completion: @escaping (Bool) -> Void) {
        let collection = collection.collection
        let time = Date().timeStamp()
        let system = NetworkCollection.system.collection
        Firestore.firestore().collection(collection).document(name).setData(data) { error in
            if error != nil {
                completion(false)
            } else {
                // обновление даты в system
                self.updateValueElement(to: .system, document: system, key: collection, value: time)
                completion(true)
            }
        }
    }
    
    // изменить значение поля элемента в коллекции
    func updateValueElement(to collection: NetworkCollection, document: String, key: String, value: Any) {
        let collection = collection.collection
        Firestore.firestore().collection(collection).document(document).updateData([key : value])
    }
    
    // удалить карточку
    func deleteElement(to collection: NetworkCollection, document: String, completion: @escaping (Bool) -> Void) {
        let collection = collection.collection
        let time = Date().timeStamp()
        let system = NetworkCollection.system.collection
        Firestore.firestore().collection(collection).document(document).delete() { error in
            if error != nil {
                completion(false)
            } else {
                self.updateValueElement(to: .system, document: system, key: collection, value: time)
                completion(true)
            }
        }
    }
    
    // MARK: -  работа с хранилищем кодирование и декодирование загрузка и выгрузка файлов ввиде Data
    // сохранение файла с автоматическим uuid - возвращает путь к файлу
    func upLoadFile<T: Encodable>(to name: String? = nil, type: UploadType, model: T.Type, collection: Any, completion: @escaping (String) -> Void) {
        var uuid = UUID().uuidString
        if let name = name { uuid = name }
        let storageRef = type.filePath.child(uuid)
        if let collection = collection as? T {
            do {
                let data = try JSONEncoder().encode(collection)
                storageRef.putData(data, metadata: nil) { _, error in
                    if error != nil {
                        print("ERROR: upLoad File")
                        completion("")
                    } else {
                        print("FINISH: upLoad File \(uuid)")
                        completion(uuid)
                    }
                }
            } catch {
                print("Ошибка кодирования файла перед сохранением")
            }
        }
    }
    // загрузка файла по названию и типу
    func loadFile<T: Decodable>(type: UploadType, name: String, model: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        let storageRef = type.filePath.child(name)
        storageRef.getData(maxSize: 5 * 1024 * 1024 ) { data, error in
            if let error = error {
                print("NetworkManager ERROR: loadFile  type \(type)", error.localizedDescription)
                completion(.failure(.loadFile))
            } else {
                if let data = data {
                    do {
                        let decoder = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(decoder))
                    } catch {
                        completion(.failure(.decodeStorage))
                    }
                }
            }
        }
    }
    // удаление файла
    func deleteFile(type: UploadType, name: String,completion: @escaping (Bool) -> Void) {
        let storageRef = type.filePath.child(name)
        storageRef.delete { error in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
}
