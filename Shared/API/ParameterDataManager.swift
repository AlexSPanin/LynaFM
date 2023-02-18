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
        NetworkManager.shared.fetchSubCollection(to: .parameter, doc: doc, sub: .elements, model: ParameterElement.self) { cards in
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
            NetworkManager.shared.fetchElementSubCollection(to: .parameter, doc: doc,
                                                            sub: .elements, element: element, model: ParameterElement.self) { card in
                if let card = card {
                    completion(card)
                } else {
                    print("Ошибка загрузки карточки из сети \(element)")
                    completion(nil)
                }
            }
        }
    }
    
    //MARK: - обновление всех карточek коллекции
    func updateCards(to cards: [Parameter], completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        cards.forEach { card in
            myGroup.enter()
            upLoadParameter(param: card) { _ in
                NetworkManager.shared.updateTimeStamp(to: .parameter, doc: card.id, sub: .elements)
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
           completion(true)
        }
    }
    
    //MARK: - обновление всех карточek под коллекции
    func updateSubCards(to doc: String, cards: [ParameterElement], completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        cards.forEach { card in
            myGroup.enter()
            upLoadParameterElement(to: doc, param: card) { _ in
                NetworkManager.shared.updateTimeStamp(to: .parameter, doc: doc, sub: .elements, element: card.id)
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
           completion(true)
        }
    }
    
    //MARK: - обновление карточки коллекции
    func updateCard(to card: Parameter, completion: @escaping(Bool) -> Void) {
        print("Обновление карточки пользователя \(card.name)")
        upLoadParameter (param: card) { status in
            NetworkManager.shared.updateTimeStamp(to: .parameter, doc: card.id, sub: .elements)
            completion(status)
        }
    }
    
    //MARK: - обновление карточки под коллекции
    func updateSubCard(to doc: String, element: ParameterElement, completion: @escaping(Bool) -> Void) {
        print("Обновление карточки пользователя \(element.name)")
        upLoadParameterElement(to: doc, param: element) { status in
            NetworkManager.shared.updateTimeStamp(to: .parameter, doc: doc, sub: .elements, element: element.id)
            completion(status)
        }
    }
    //MARK: - загрузка файла
    func loadFileImage(to file: String, completion: @escaping(Data?) -> Void) {
        print("Сохранение файла \(file)")
        FileAppManager.shared.loadFileData(to: file, type: .assets) { data in
            if let data = data {
                completion(data)
            } else {
                NetworkManager.shared.loadFile(type: .image, name: file) { data in
                    if let data = data {
                        FileAppManager.shared.saveFileData(to: file, type: .assets, data: data)
                    }
                    completion(data)
                }
            }
        }
    }
    
    //MARK: - сохранение файла
    func saveFileImage(to file: String?, doc: String, element: String? = nil, completion: @escaping(Bool) -> Void) {
        if let file = file {
            print("Сохранение файла \(file)")
            FileAppManager.shared.loadFileData(to: file, type: .assets) { data in
                if let data = data {
                    NetworkManager.shared.upLoadFile(to: file, type: .image, data: data) { _ in
                        print("Сохранен файл \(file)")
                        NetworkManager.shared.updateTimeStamp(to: .parameter, doc: doc, sub: .elements, element: element)
                        completion(true)
                    }
                } else {
                    print("Файл не найден \(file)")
                    completion(false)
                }
            }
        }
    }
    
    func saveFile(to file: String, doc: String, element: String? = nil, completion: @escaping(Bool) -> Void) {
        print("Сохранение файла \(file)")
        FileAppManager.shared.loadFileData(to: file, type: .temp) { data in
            if let data = data {
                NetworkManager.shared.upLoadFile(to: file, type: .data, data: data) { _ in
                    print("Сохранен файл \(file)")
                    NetworkManager.shared.updateTimeStamp(to: .parameter, doc: doc, sub: .elements, element: element)
                    completion(true)
                }
            } else {
                print("Файл не найден \(file)")
                completion(false)
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
                NetworkManager.shared.updateTimeStamp(to: .parameter, doc: doc, sub: .elements)
                completion(status)
            }
        }
    }
    //MARK: - удалить карточку коллекции
    func deleteCard(to card: Parameter, completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        card.images.forEach { image in
            myGroup.enter()
            NetworkManager.shared.deleteFile(type: .image, name: image) { _ in
                myGroup.leave()
            }
        }
        card.files.forEach { file in
            myGroup.enter()
            NetworkManager.shared.deleteFile(type: .data, name: file) { _ in
                myGroup.leave()
            }
        }
        
        NetworkManager.shared.fetchSubCollection(to: .parameter, doc: card.id, sub: .elements, model: ParameterElement.self) { elements in
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
    

    //MARK: - удалить карточку коллекции
    func deleteSubCard(to card: ParameterElement, completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        card.images.forEach { image in
            myGroup.enter()
            NetworkManager.shared.deleteFile(type: .image, name: image) { _ in
                myGroup.leave()
            }
        }
        
        card.files.forEach { file in
            myGroup.enter()
            NetworkManager.shared.deleteFile(type: .data, name: file) { _ in
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            NetworkManager.shared.deleteSubElement(to: .parameter, document: card.idCollection,
                                                   sub: .elements, element: card.id) { status in
                NetworkManager.shared.updateTimeStamp(to: .parameter, doc: card.idCollection, sub: .elements)
                completion(status)
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
        let data = ["id" : id,
                    "date" : param.date,
                    "idUser" : param.idUser,
                    "isActive" : param.isActive,
                    "countUse" : param.countUse,
                    
                    "sort" : param.sort,
                    "type" : param.type,
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
        let data = ["id" : id,
                    "idCollection" : doc,
                    "date" : param.date,
                    "idUser" : param.idUser,
                    "isActive" : param.isActive,
                    "countUse" : param.countUse,
                    
                    "sort" : param.sort,
                    "name" : param.name,
                    "value" : param.value,
                    "images" : param.images,
                    "files" : param.files] as [String : Any]
            NetworkManager.shared.upLoadElementSubCollection(to: .parameter, doc: doc, sub: .elements, name: id, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }
}
