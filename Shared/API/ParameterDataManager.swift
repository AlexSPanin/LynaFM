//
//  ParametrDataManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.02.2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


class ParameterDataManager {
    static let shared = ParameterDataManager()
    private init() {}
    
    //MARK: - загрузка всех карточк коллекции
    func loadCollection(completion: @escaping([Parameter]?) -> Void) {
        NetworkManager.shared.fetchCollection(to: .parameter, model: Parameter.self) { cards in
            if let cards = cards {
                print("Коллекция из сети загружена")
                    completion(cards)
            } else {
                print("Ошибка: сбой обнавления коллекции.")
                completion(nil)
            }
        }
    }
    
    //MARK: - загрузка всех карточк под коллекции
    func loadSubCollection(to doc: String, completion: @escaping([ParameterElement]?) -> Void) {
        NetworkManager.shared.fetchSubCollection(to: .parameter, doc: doc, model: ParameterElement.self) { cards in
            if let cards = cards {
                print("Под Коллекция из сети загружена")
                    completion(cards)
            } else {
                print("Ошибка: сбой обнавления под коллекции.")
                completion(nil)
            }
        }
    }
    
    //MARK: - загрузка карточки коллекции
    func loadCard(to doc: String?, completion: @escaping(Parameter?) -> Void) {
        if let doc = doc {
            NetworkManager.shared.fetchElementCollection(to: .parameter, doc: doc, model: Parameter.self) { card in
                if let card = card {
                    completion(card)
                } else {
                    print("Ошибка загрузки карточки из сети \(doc)")
                    completion(nil)
                }
            }
        }
    }
    
    //MARK: - загрузка карточки коллекции
    func loadSubCard(to doc: String, element: String?, completion: @escaping(ParameterElement?) -> Void) {
        if let element = element {
            NetworkManager.shared.fetchElementSubCollection(to: .parameter, doc: doc, element: element, model: ParameterElement.self) { card in
                if let card = card {
                    completion(card)
                } else {
                    print("Ошибка загрузки карточки из сети \(element)")
                    completion(nil)
                }
            }
        }
    }
    
    //MARK: - обновление карточки коллекции
    func updateCard(to card: Parameter, completion: @escaping(Bool) -> Void) {
        print("Обновление карточки пользователя \(card.name)")
        upLoadParameter (param: card) { status in
            completion(status)
        }
    }
    
    //MARK: - обновление карточки под коллекции
    func updateCard(to doc: String, card: ParameterElement, completion: @escaping(Bool) -> Void) {
        print("Обновление карточки пользователя \(card.name)")
        upLoadParameterElement(to: doc, param: card) { status in
            completion(status)
        }
    }
    
    //MARK: - сохранение файла
    func saveFileImage(to file: String, doc: String, element: String? = nil, completion: @escaping(Bool) -> Void) {
        print("Сохранение файла \(file)")
        FileAppManager.shared.loadFileData(to: file, type: .assets) { data in
            if let data = data {
                NetworkManager.shared.upLoadFile(to: file, type: .parameter, data: data) { _ in
                    print("Сохранен файл \(file)")
                    NetworkManager.shared.updateTimeStamp(to: .parameter, doc: doc, element: element)
                }
            } else {
                print("Файл не найден \(file)")
            }
        }
    }
    
    func saveFile(to file: String, doc: String, element: String? = nil, completion: @escaping(Bool) -> Void) {
        print("Сохранение файла \(file)")
        FileAppManager.shared.loadFileData(to: file, type: .temp) { data in
            if let data = data {
                NetworkManager.shared.upLoadFile(to: file, type: .parameter, data: data) { _ in
                    print("Сохранен файл \(file)")
                    NetworkManager.shared.updateTimeStamp(to: .parameter, doc: doc, element: element)
                }
            } else {
                print("Файл не найден \(file)")
            }
        }
    }
        
        
    //MARK: - создать новую карточку коллекции
    func createCard(to card: Parameter, completion: @escaping(Bool) -> Void) {
        print("Создание новой карточки коллекции\(card.name)")
        let myGroup = DispatchGroup()
        
        card.images.forEach { image in
            myGroup.enter()
            saveFileImage(to: image, doc: card.id) { _ in
                myGroup.leave()
            }
        }
        
        card.files.forEach { file in
            myGroup.enter()
            saveFile(to: file, doc: card.id) { _ in
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            print("Сохранена карточка коллекции\(card.name)")
            self.upLoadParameter(param: card) { status in
                completion(status)
            }
        }
    }
    
    //MARK: - создать новую карточку под коллекции
    func createSubCard(to doc: String, card: ParameterElement, completion: @escaping(Bool) -> Void) {
        print("Создание новой карточки под коллекции \(card.name)")
        let myGroup = DispatchGroup()
        
        card.images.forEach { image in
            myGroup.enter()
            saveFileImage(to: image, doc: doc, element: card.id) { _ in
                myGroup.leave()
            }
        }
        
        card.files.forEach { file in
            myGroup.enter()
            saveFile(to: file, doc: doc, element: card.id) { _ in
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            print("Сохранена карточка под коллекции \(card.name)")
            self.upLoadParameterElement(to: doc, param: card) { status in
                completion(status)
            }
        }
    }
    //MARK: - удалить карточку коллекции
    func deleteCard(to card: Parameter, completion: @escaping(Bool) -> Void) {
        if card.countUse == 0 {
            let myGroup = DispatchGroup()
            card.images.forEach { image in
                myGroup.enter()
                NetworkManager.shared.deleteFile(type: .parameter, name: image) { _ in
                    myGroup.leave()
                }
            }
            card.files.forEach { file in
                myGroup.enter()
                NetworkManager.shared.deleteFile(type: .parameter, name: file) { _ in
                    myGroup.leave()
                }
            }
            
            NetworkManager.shared.fetchSubCollection(to: .parameter, doc: card.id, model: ParameterElement.self) { elements in
                elements?.forEach({ element in
                    myGroup.enter()
                    self.deleteSubCard(to: element) { _ in
                        myGroup.leave()
                    }
                })
            }
            
            myGroup.notify(queue: .main) {
                NetworkManager.shared.deleteElement(to: .parameter, document: card.id) { status in
                    completion(status)
                }
            }
        }
    }
    
    //MARK: - удалить карточку коллекции
    func deleteSubCard(to card: ParameterElement, completion: @escaping(Bool) -> Void) {
        if card.countUse == 0 {
            let myGroup = DispatchGroup()
            card.images.forEach { image in
                myGroup.enter()
                NetworkManager.shared.deleteFile(type: .parameter, name: image) { _ in
                    myGroup.leave()
                }
            }
            
            card.files.forEach { file in
                myGroup.enter()
                NetworkManager.shared.deleteFile(type: .parameter, name: file) { _ in
                    myGroup.leave()
                }
            }
            
            myGroup.notify(queue: .main) {
                NetworkManager.shared.deleteSubElement(to: .parameter, document: card.idCollection, element: card.id) { status in
                    NetworkManager.shared.updateTimeStamp(to: .parameter, doc: card.idCollection)
                    completion(status)
                }
            }
        }
    }
    
    //MARK: - методы работы с параметрами товара
    // сохранение карточки параметров товара
    func upLoadParameter(param: Parameter?, completion: @escaping (Bool) -> Void) {
        let collection = NetworkCollection.stage.collection
        if let param = param {
            var id = param.id
            if param.id.isEmpty {
                id = Firestore.firestore().collection(collection).document().documentID
            }
        let data = ["id:" : id,
                    "date" : param.date,
                    "idUser" : param.idUser,
                    "isActive" : param.isActive,
                    "countUse" : param.countUse,
                    
                    "sort" : param.sort,
                    "name" : param.name,
                    "label" : param.label,
                    "images" : param.images,
                    "files" : param.files] as [String : Any]
            NetworkManager.shared.upLoadElementCollection(to: .parameter, name: id, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }
    
    // сохранение карточки параметров товара
    func upLoadParameterElement(to doc: String, param: ParameterElement?, completion: @escaping (Bool) -> Void) {
        let collection = NetworkCollection.stage.collection
        if let param = param {
            var id = param.id
            if param.id.isEmpty {
                id = Firestore.firestore().collection(collection).document().documentID
            }
        let data = ["id:" : id,
                    "idCollection" : doc,
                    "date" : param.date,
                    "idUser" : param.idUser,
                    "isActive" : param.isActive,
                    "countUse" : param.countUse,
                    
                    "sort" : param.sort,
                    "name" : param.name,
                    "label" : param.label,
                    "images" : param.images,
                    "files" : param.files] as [String : Any]
            NetworkManager.shared.upLoadElementSubCollection(to: .parameter, doc: doc, name: id, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }
}
