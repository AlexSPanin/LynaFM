//
//  MaterialDataManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.02.2023.
//

import Foundation

class MaterialDataManager {
    static let shared = MaterialDataManager()
    private init() {}
    
    //MARK: - загрузка всех карточк
    func loadCollection(completion: @escaping(Result<[MaterialAPP], NetworkError>) -> Void) {
        let myGroup = DispatchGroup()
        NetworkManager.shared.fetchFullCollection(to: .material, model: Material.self) { result in
            switch result {
            case .success(let cards):
                print("Коллекция из сети загружена")
                var cardsAPP = [MaterialAPP]()
                cards.forEach { card in
                    myGroup.enter()
                    self.loadCard(to: card.id) { result in
                        switch result {
                        case .success(let cardAPP):
                            cardsAPP.append(cardAPP)
                            myGroup.leave()
                        case .failure(_):
                            print("Ошибка загрузки карточки \(card.name)")
                            myGroup.leave()
                        }
                    }
                }
                myGroup.notify(queue: .main) {
                    completion(.success(cardsAPP))
                }
            case .failure(_):
                print("Ошибка: сбой обнавления коллекции.")
                completion(.failure(.fetchCollection))
            }
        }
    }
    
    //MARK: - загрузка карточки
    func loadCard(to id: String?, completion: @escaping(Result<MaterialAPP, NetworkError>) -> Void) {
        if let id = id {
            NetworkManager.shared.fetchElementCollection(to: .material, doc: id, model: Material.self) { result in
                switch result {
                case .success(let card):
                    self.convertCardToCardAPP(card: card) { cardAPP in
                        completion(.success(cardAPP))
                    }
                case .failure(_):
                    print("Ошибка загрузки карточки из сети \(id)")
                    completion(.failure(.fetchUser))
                }
            }
        }
    }
    
    //MARK: - обновление карточки
    func updateCard(to cardAPP: MaterialAPP, completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        let cardID = cardAPP.id
        print("Обновление карточки пользователя \(cardAPP.name)")
        NetworkManager.shared.fetchElementCollection(to: .material, doc: cardID, model: Material.self) { result in
            switch result {
            case .success(let card):
                myGroup.enter()
                NetworkManager.shared.upLoadFile(to: card.file, type: .material_data, data: cardAPP.file) { _ in
                    print("Сохранен файл userData \(cardAPP.name)")
                    myGroup.leave()
                }
                var cardExport = self.convertToCard(cardAPP: cardAPP)
                cardExport.file = card.file
                myGroup.notify(queue: .main) {
                    print("Сохранение обновленной карточки пользователя \(cardAPP.name)")
                    NetworkManager.shared.upLoadMaterial (to: cardID, material: cardExport) { status in
                        completion(status)
                    }
                }
            case .failure(_):
                print("Ошибка загрузки карточки пользователя из сети \(cardAPP.name)")
                completion(false)
            }
        }
    }
    //MARK: - обновить image
    func updateImage(to name: String, data: Data, completion: @escaping(Bool) -> Void) {
        NetworkManager.shared.upLoadFile(to: name, type: .material_image, data: data) { [self] _ in
            self.updateTimeStamp()
            completion(true)
        }
    }
    //MARK: - удалить image
    func deleteImage(to cardAPP: MaterialAPP, name: String, completion: @escaping(Bool) -> Void) {
        var images = cardAPP.images
        images.removeValue(forKey: name)
        let collection = images as Any
        NetworkManager.shared.updateValueElement(to: .material, document: cardAPP.id, key: "images", value: collection)
        NetworkManager.shared.deleteFile(type: .material_image, name: name) { status in
            self.updateTimeStamp()
            completion(status)
        }
    }
    //MARK: - добавить image
    func addImage(to cardAPP: MaterialAPP, data: Data, sort: Int, completion: @escaping(Bool) -> Void) {
        var images = cardAPP.images
        NetworkManager.shared.upLoadFile(type: .material_image, data: data) { file in
            images[file] = sort
            let collection = images as Any
            NetworkManager.shared.updateValueElement(to: .material, document: cardAPP.id, key: "images", value: collection)
            self.updateTimeStamp()
            completion(true)
        }
    }
    //MARK: - сохранить изменения порядка сортировки
    func updateSort(to cardAPP: MaterialAPP, completion: @escaping(Bool) -> Void) {
        let collection = cardAPP.images as Any
        NetworkManager.shared.updateValueElement(to: .material, document: cardAPP.id, key: "images", value: collection)
        self.updateTimeStamp()
        completion(true)
    }
    
    //MARK: - создать новую карточку
    func createNewCard(to cardAPP: MaterialAPP, images: [Data], completion: @escaping(Bool) -> Void) {
        print("Создание новой карточки \(cardAPP.name)")
        let myGroup = DispatchGroup()
        let data = cardAPP.file
        var card = convertToCard(cardAPP: cardAPP)
        
        myGroup.enter()
        NetworkManager.shared.upLoadFile(to: nil, type: .material, data: data) { file in
            print("Сохранен файл \(card.name)")
            card.file = file
            myGroup.leave()
        }
        
        for index in 0..<images.count {
            myGroup.enter()
            let image = images[index]
            NetworkManager.shared.upLoadFile(type: .material_image, data: image) { file in
                card.images[file] = index
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
            print("Сохранена карточка \(card.name)")
            NetworkManager.shared.upLoadMaterial(to: nil, material: card) { status in
                completion(status)
            }
        }
    }
    
    //MARK: - удалить карточку
    func deleteCard(to cardAPP: MaterialAPP, completion: @escaping(String, Bool) -> Void) {
        if cardAPP.countUse != 0 {
            let errorText = "Карточка используется в \(cardAPP.countUse) документах."
            let error = true
            completion(errorText,error)
        } else {
            
            NetworkManager.shared.fetchElementCollection(to: .material, doc: cardAPP.id, model: Material.self) { result in
                switch result {
                case .success(let card):
                    NetworkManager.shared.deleteFile(type: .material_data, name: card.file) { status in
                        if !status {
                            print("Ошибка удаления файла \(card.file)")
                        }
                    }
                case .failure(_):
                    print("Ошибка загрузки карточки \(cardAPP.name)")
                }
            }
            
            cardAPP.images.forEach { image in
                NetworkManager.shared.deleteFile(type: .material_image, name: image.key) { status in
                    if !status {
                        print("Ошибка удаления файла \(image)")
                    }
                }
            }
            
            NetworkManager.shared.deleteElement(to: .material, document: cardAPP.id) { status in
                if status {
                    self.updateTimeStamp()
                    completion("", false)
                } else {
                    let errorText = "Ошибка удаление карточки \(cardAPP.countUse)."
                    let error = true
                    completion(errorText,error)
                }
            }
        }
    }
    
    
    //MARK: - конвертации
    private func convertCardToCardAPP(card: Material, completion: @escaping(MaterialAPP) -> Void) {
        let myGroup = DispatchGroup()
        var current = MaterialAPP()
        current.id = card.id
        current.date = card.date
        current.idUser = card.idUser
        current.idGroup = card.idGroup
        current.isActive = card.isActive
        current.countUse = card.countUse
        
        current.sort = card.sort
        current.article = card.article
        current.name = card.name
        current.label = card.label
        current.images = card.images
        
        myGroup.enter()
        NetworkManager.shared.loadFile(type: .material_data, name: card.file) { result in
            switch result {
            case .success(let data):
                current.file = data
                myGroup.leave()
            case .failure(_):
                print("Ошибка загрузки файла \(card.name)")
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
            print("Сохранение обновленной карточки пользователя \(card.name)")
            completion(current)
        }
    }
    
    private func convertToCard(cardAPP: MaterialAPP) -> Material {
        var card = Material()
        card.id = cardAPP.id
        card.date = cardAPP.date
        card.idUser = cardAPP.idUser
        card.idGroup = cardAPP.idGroup
        card.isActive = cardAPP.isActive
        card.countUse = cardAPP.countUse
        
        card.sort = cardAPP.sort
        card.article = cardAPP.article
        card.name = cardAPP.name
        card.label = cardAPP.label
        card.images = cardAPP.images
        return card
    }
    
    private func updateTimeStamp() {
        let collection = NetworkCollection.material.collection
        let time = Date().timeStamp()
        let system = NetworkCollection.system.collection
        NetworkManager.shared.updateValueElement(to: .system, document: system, key: collection, value: time)
    }
}
