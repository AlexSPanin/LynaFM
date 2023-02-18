//
//  GroupDataManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.02.2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class GroupDataManager {
    static let shared = GroupDataManager()
    private init() {}
    
    //MARK: - загрузка всех карточк
    func loadCollection(completion: @escaping([Group]?) -> Void) {
        NetworkManager.shared.fetchCollection(to: .group, model: Group.self) { cards in
            if let cards = cards {
                print("Коллекция из сети загружена")
                    completion(cards)
            } else {
                print("Ошибка: сбой обнавления коллекции.")
                completion(nil)
            }
        }
    }
    
    //MARK: - загрузка карточки
    func loadCard(to doc: String?, completion: @escaping(Group?) -> Void) {
        if let doc = doc {
            NetworkManager.shared.fetchElementCollection(to: .group, doc: doc, model: Group.self) { card in
                if let card = card {
                    completion(card)
                } else {
                    print("Ошибка загрузки карточки из сети \(doc)")
                    completion(nil)
                }
            }
        }
    }
    //MARK: - обновление всех карточek коллекции
    func updateCards(to cards: [Group], completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        cards.forEach { card in
            myGroup.enter()
            upLoadGroup(group: card) { _ in
                NetworkManager.shared.updateTimeStamp(to: .group, doc: card.id, sub: nil)
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
           completion(true)
        }
    }
    //MARK: - обновление карточки
    func updateCard(to card: Group, completion: @escaping(Bool) -> Void) {
        print("Обновление карточки пользователя \(card.name)")
        upLoadGroup (group: card) { status in
            NetworkManager.shared.updateTimeStamp(to: .group, doc: card.id, sub: nil)
            completion(status)
        }
    }
    
    //MARK: - создать новую карточку
    func createCard(to card: Group, completion: @escaping(Bool) -> Void) {
        print("Создание новой карточки \(card.name)")
        let myGroup = DispatchGroup()

        myGroup.enter()
        saveFileImage(to: card.image, doc: card.id) { _ in
            myGroup.leave()
        }
        
        myGroup.notify(queue: .main) {
            print("Сохранена карточка \(card.name)")
            self.upLoadGroup(group: card) { status in
                completion(status)
            }
        }
    }
    
    //MARK: - удалить карточку
    func deleteCard(to card: Group, completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        myGroup.enter()
        NetworkManager.shared.deleteFile(type: .image, name: card.image) { _ in
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            NetworkManager.shared.deleteElement(to: .group, document: card.id) { status in
                completion(status)
            }
        }
    }
    
    //MARK: - сохранение файла
    func saveFileImage(to file: String?, doc: String, completion: @escaping(Bool) -> Void)  {
        if let file = file {
            print("Сохранение файла \(file)")
            FileAppManager.shared.loadFileData(to: file, type: .assets) { data in
                if let data = data {
                    NetworkManager.shared.upLoadFile(to: file, type: .image, data: data) { _ in
                        print("Сохранен файл \(file)")
                        NetworkManager.shared.updateTimeStamp(to: .group, doc: doc, sub: nil)
                        completion(true)
                    }
                } else {
                    print("Файл не найден \(file)")
                    completion(false)
                }
            }
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
    
    //MARK: - методы работы с продуктовой группы
    // сохранение карточки продуктовой группы
    private func upLoadGroup(group: Group?, completion: @escaping (Bool) -> Void) {
        let collection = NetworkCollection.group.collection
        if let group = group {
            var id = group.id
            if group.id.isEmpty {
                id = Firestore.firestore().collection(collection).document().documentID
            }
            let data = ["id" : id,
                        "date" : group.date,
                        "idUser" : group.idUser,
                        "isActive" : group.isActive,
                        "countUse" : group.countUse,
                        
                        "type" : group.type,
                        "preGroup" : group.preGroup,
                        "afterGroup" : group.afterGroup,
                        
                        "sort" : group.sort,
                        "name" : group.name,
                        "label" : group.label,
                        "image" : group.image
            ] as [String : Any]
            NetworkManager.shared.upLoadElementCollection(to: .group, name: id, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }
}
