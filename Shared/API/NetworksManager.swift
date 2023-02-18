//
//  NetworksManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//
//MARK: -  методы для работы с FB
import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    //MARK: - методы работы с типом продукты
    // сохранение карточки продукты
    func upLoadProduct(to id: String?, product: Product?, completion: @escaping (Bool) -> Void) {
        let collection = NetworkCollection.product.collection
        let id = id != nil ? id : Firestore.firestore().collection(collection).document().documentID
        if let product = product, let id = id {
            let data = ["id" : id,
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
    
    
    // MARK: -  работа с хранилищем загрузка и выгрузка файлов ввиде Data
    // сохранение файла с автоматическим uuid - возвращает путь к файлу
    func upLoadFile(to name: String? = nil, type: UploadType, data: Data, completion: @escaping (String) -> Void) {
        var uuid = UUID().uuidString
        if let name = name { uuid = name }
        let storageRef = type.filePath.child(uuid)
        storageRef.putData(data, metadata: nil) { _, error in
            if error != nil {
                print("ОШИБКА: ззаписи файла в FB \(uuid)")
                completion("")
            } else {
                completion(uuid)
            }
        }
    }
    // загрузка файла по названию и типу
    func loadFile(type: UploadType, name: String, completion: @escaping (Data?) -> Void) {
        let storageRef = type.filePath.child(name)
        storageRef.getData(maxSize: 5 * 1024 * 1024 ) { data, _ in
            completion(data)
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
    func fetchSubCollection<T: Decodable>(to collection: NetworkCollection, doc: String, sub: NetworkCollection, model: T.Type, comletion: @escaping ([T]?) -> Void ) {
        Firestore.firestore().collection(collection.collection).document(doc).collection(sub.collection).getDocuments { querySnapshot, _ in
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
    func fetchElementSubCollection<T: Decodable>(to collection: NetworkCollection, doc: String, sub: NetworkCollection, element: String, model: T.Type, comletion: @escaping (T?) -> Void ) {
        Firestore.firestore().collection(collection.collection).document(doc).collection(sub.collection).document(element).getDocument(as: T.self) { result in
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
        Firestore.firestore().collection(collection.collection).document(name).setData(data) { error in
            completion(error == nil)
        }
    }
    
    // записать элемент под коллекции [String: Any]
    func upLoadElementSubCollection(to collection: NetworkCollection, doc: String, sub: NetworkCollection, name: String, data: [String : Any], completion: @escaping (Bool) -> Void) {
        Firestore.firestore().collection(collection.collection).document(doc).collection(sub.collection).document(name).setData(data) { error in
            completion(error == nil)
        }
    }
    
    // изменить значение поля элемента в коллекции
    func updateValueElement(to collection: NetworkCollection, document: String, key: String, value: Any) {
        Firestore.firestore().collection(collection.collection).document(document).updateData([key : value])
    }
    
    // изменить значение поля элемента в под коллекции
    func updateValueSubElement(to collection: NetworkCollection, document: String, sub: NetworkCollection, element: String, key: String, value: Any) {
        Firestore.firestore().collection(collection.collection).document(document).collection(sub.collection).document(element).updateData([key : value])
    }
    
    // удалить карточку коллекции
    func deleteElement(to collection: NetworkCollection, document: String, completion: @escaping (Bool) -> Void) {
        let collection = collection.collection
        Firestore.firestore().collection(collection).document(document).delete() { error in
            completion(error == nil)
        }
    }
    
    // удалить карточку под коллекции
    func deleteSubElement(to collection: NetworkCollection, document: String, sub: NetworkCollection, element: String, completion: @escaping (Bool) -> Void) {
        let collection = collection.collection
        Firestore.firestore().collection(collection).document(document).collection(sub.collection).document(element).delete() { error in
            completion(error == nil)
        }
    }
    
    // MARK: -  работа с хранилищем кодирование и декодирование загрузка и выгрузка файлов ввиде Data
    // сохранение файла с автоматическим uuid - возвращает путь к файлу
    func upLoadFile<T: Encodable>(to name: String, type: UploadType, model: T.Type, collection: Any, completion: @escaping () -> Void) {
        let storageRef = type.filePath.child(name)
        if let collection = collection as? T {
            do {
                let data = try JSONEncoder().encode(collection)
                storageRef.putData(data, metadata: nil) { _, error in
                    completion()
                }
            } catch {
                print("Ошибка кодирования файла перед сохранением \(name)")
                completion()
            }
        }
    }
    //MARK: - загрузка файла по названию и типу
    func loadFile<T: Decodable>(type: UploadType, name: String, model: T.Type, completion: @escaping (T?) -> Void) {
        let storageRef = type.filePath.child(name)
        storageRef.getData(maxSize: 5 * 1024 * 1024 ) { data, _ in
            if let data = data {
                completion( try? JSONDecoder().decode(T.self, from: data))
            } else {
                completion(nil)
            }
        }
    }
    //MARK: - удаление файла
    func deleteFile(type: UploadType, name: String,completion: @escaping (Bool) -> Void) {
        let storageRef = type.filePath.child(name)
        storageRef.delete { error in
            completion(error == nil)
        }
    }
    //MARK: - изменение времени обновления карточки коллекции
    func updateTimeStamp(to collection: NetworkCollection, doc: String, sub: NetworkCollection?, element: String? = nil) {
        let time = Date().timeStamp() as Any
        if let sub = sub, let element = element {
            NetworkManager.shared.updateValueSubElement(to: collection, document: doc,
                                                        sub: sub, element: element,
                                                        key: "date", value: time)
        } else {
            NetworkManager.shared.updateValueElement(to: collection, document: doc, key: "date", value: time)
        }
    }
}
