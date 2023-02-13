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
        let id = id != nil ? id : Firestore.firestore().collection(collection).document().documentID
        if let product = product, let id = id {
            let data = ["id:" : id,
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
            upLoadElementCollection(to: .product, name: id, data: data) { status in
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
        let id = id != nil ? id : Firestore.firestore().collection(collection).document().documentID
        if let material = material, let id = id {
        let data = ["id:" : id,
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
        upLoadElementCollection(to: .material, name: id, data: data) { status in
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
        let id = id != nil ? id : Firestore.firestore().collection(collection).document().documentID
        if let group = group, let id = id {
        let data = ["id:" : id,
                    "date" : group.date,
                    "idUser" : group.idUser,
                    "idType" : group.idType,
                    "isActive" : group.isActive,
                    "countUse" : group.countUse,
                    
                    "sort" : group.sort,
                    "name" : group.name,
                    "label" : group.label,
                    "file" : group.file] as [String : Any]
            upLoadElementCollection(to: .group, name: id, data: data) { status in
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
  //              print("FINISH: upLoad File \(uuid)")
                completion(uuid)
            }
        }
    }
    // загрузка файла по названию и типу
    func loadFile(type: UploadType, name: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let storageRef = type.filePath.child(name)
        storageRef.getData(maxSize: 5 * 1024 * 1024 ) { data, error in
            if error != nil {
                completion(.failure(.loadFile))
            } else {
                guard let dataFile = data else { return }
                completion(.success(dataFile))
            }
        }
    }
    
    // MARK: - работа с коллекцией
    // получить весь список из коллекции ввиде [QueryDocumentSnapshot]
    func fetchCollection<T: Decodable>(to collection: NetworkCollection, model: T.Type, comletion: @escaping ([T]?) -> Void ) {
        Firestore.firestore().collection(collection.collection).getDocuments { querySnapshot, _ in
            if let documents = querySnapshot?.documents {
                let datas = documents.compactMap({ try? $0.data(as: T.self)})
                comletion(datas)
            } else {
                print("Документы не получены")
                comletion(nil)
            }
        }
    }
    
    // получить элемент коллекции DocumentSnapshot
    func fetchElementCollection<T: Decodable>(to collection: NetworkCollection, doc: String, model: T.Type, comletion: @escaping (T?) -> Void ) {
        Firestore.firestore().collection(collection.collection).document(doc).getDocument(as: T.self) { result in
            switch result {
            case .success(let doc):
                comletion(doc)
            case .failure(_):
                comletion(nil)
            }
        }
    }
    
    // получить весь список из под коллекции ввиде [QueryDocumentSnapshot]
    func fetchSubCollection<T: Decodable>(to collection: NetworkCollection, doc: String, model: T.Type, comletion: @escaping ([T]?) -> Void ) {
        Firestore.firestore().collection(collection.collection).document(doc).collection("elements").getDocuments { querySnapshot, _ in
            if let documents = querySnapshot?.documents {
                let datas = documents.compactMap({ try? $0.data(as: T.self)})
                comletion(datas)
            } else {
                print("Документы под коллекции не получены")
                comletion(nil)
            }
        }
    }
    
    // получить элемент из под коллекции DocumentSnapshot
    func fetchElementSubCollection<T: Decodable>(to collection: NetworkCollection, doc: String, element: String, model: T.Type, comletion: @escaping (T?) -> Void ) {
        Firestore.firestore().collection(collection.collection).document(doc).collection("elements").document(element).getDocument(as: T.self) { result in
            switch result {
            case .success(let doc):
                comletion(doc)
            case .failure(_):
                comletion(nil)
            }
        }
    }
    
    // записать элемент коллекции [String: Any]
    func upLoadElementCollection(to collection: NetworkCollection, name: String, data: [String : Any], completion: @escaping (Bool) -> Void) {
        let collection = collection.collection
        Firestore.firestore().collection(collection).document(name).setData(data) { error in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // записать элемент под коллекции [String: Any]
    func upLoadElementSubCollection(to collection: NetworkCollection, doc: String, name: String, data: [String : Any], completion: @escaping (Bool) -> Void) {
        let collection = collection.collection
        Firestore.firestore().collection(collection).document(doc).collection("elements").document(name).setData(data) { error in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    
    
    
    // изменить значение поля элемента в коллекции
    func updateValueElement(to collection: NetworkCollection, document: String, key: String, value: Any) {
        let collection = collection.collection
        Firestore.firestore().collection(collection).document(document).updateData([key : value])
    }
    
    // изменить значение поля элемента в под коллекции
    func updateValueSubElement(to collection: NetworkCollection, document: String, element: String, key: String, value: Any) {
        let collection = collection.collection
        Firestore.firestore().collection(collection).document(document).collection("elements").document(element).updateData([key : value])
    }
    
    // удалить карточку коллекции
    func deleteElement(to collection: NetworkCollection, document: String, completion: @escaping (Bool) -> Void) {
        let collection = collection.collection
        Firestore.firestore().collection(collection).document(document).delete() { error in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    // удалить карточку под коллекции
    func deleteSubElement(to collection: NetworkCollection, document: String, element: String, completion: @escaping (Bool) -> Void) {
        let collection = collection.collection
        Firestore.firestore().collection(collection).document(document).collection("elements").document(element).delete() { error in
            if error != nil {
                completion(false)
            } else {
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
                        completion("")
                    } else {
                        completion(uuid)
                    }
                }
            } catch {
                print("Ошибка кодирования файла перед сохранением")
                completion("")
            }
        }
    }
    // загрузка файла по названию и типу
    func loadFile<T: Decodable>(type: UploadType, name: String, model: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        let storageRef = type.filePath.child(name)
        storageRef.getData(maxSize: 5 * 1024 * 1024 ) { data, error in
            if error != nil {
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
    
    func updateTimeStamp(to collection: NetworkCollection, doc: String, element: String? = nil) {
        let time = Date().timeStamp() as Any
        if let element = element {
            NetworkManager.shared.updateValueSubElement(to: collection, document: doc, element: element, key: "date", value: time)
        } else {
            NetworkManager.shared.updateValueElement(to: collection, document: doc, key: "date", value: time)
        }
    }
}
