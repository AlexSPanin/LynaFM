//
//  ProductDataManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.02.2023.
//

import Foundation

class ProductDataManager {
    static let shared = ProductDataManager()
    private init() {}
    
    //MARK: - загрузка всех карточк
    func loadCollection(completion: @escaping(Result<[ProductAPP], NetworkError>) -> Void) {
        let myGroup = DispatchGroup()
        NetworkManager.shared.fetchCollection(to: .product, model: Product.self) { cards in
            if let cards = cards {
                print("Коллекция из сети загружена")
                var cardsAPP = [ProductAPP]()
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
            } else {
                print("Ошибка: сбой обнавления коллекции.")
                completion(.failure(.fetchCollection))
            }
        }
    }
    
    //MARK: - загрузка карточки
    func loadCard(to id: String?, completion: @escaping(Result<ProductAPP, NetworkError>) -> Void) {
        if let id = id {
            NetworkManager.shared.fetchElementCollection(to: .product, doc: id, model: Product.self) { card in
                if let card = card {
                    self.convertCardToCardAPP(card: card) { cardAPP in
                        completion(.success(cardAPP))
                    }
                } else {
                    print("Ошибка загрузки карточки из сети \(id)")
                    completion(.failure(.fetchUser))
                }
            }
        }
    }
    
    //MARK: - обновление карточки
    func updateCard(to cardAPP: ProductAPP, completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        let cardID = cardAPP.id
        print("Обновление карточки пользователя \(cardAPP.name)")
        NetworkManager.shared.fetchElementCollection(to: .product, doc: cardID, model: Product.self) { card in
            if let card = card {
                myGroup.enter()
                NetworkManager.shared.upLoadFile(to: card.file, type: .data, data: cardAPP.file) { _ in
                    print("Сохранен файл userData \(cardAPP.name)")
                    myGroup.leave()
                }
                var cardExport = self.convertToCard(cardAPP: cardAPP)
                cardExport.file = card.file
                myGroup.notify(queue: .main) {
                    print("Сохранение обновленной карточки пользователя \(cardAPP.name)")
                    NetworkManager.shared.upLoadProduct (to: cardID, product: cardExport) { status in
                        completion(status)
                    }
                }
            } else {
                print("Ошибка загрузки карточки пользователя из сети \(cardAPP.name)")
                completion(false)
            }
        }
    }
    //MARK: - обновить image
    func updateImage(to name: String, data: Data, completion: @escaping(Bool) -> Void) {
        NetworkManager.shared.upLoadFile(to: name, type: .image, data: data) { _ in
            self.updateTimeStamp()
            completion(true)
        }
    }
    //MARK: - удалить image
    func deleteImage(to cardAPP: ProductAPP, name: String, completion: @escaping(Bool) -> Void) {
        var images = cardAPP.images
        images.removeValue(forKey: name)
        let collection = images as Any
        NetworkManager.shared.updateValueElement(to: .product, document: cardAPP.id, key: "images", value: collection)
        NetworkManager.shared.deleteFile(type: .image, name: name) { status in
            self.updateTimeStamp()
            completion(status)
        }
    }
    //MARK: - добавить image
    func addImage(to cardAPP: ProductAPP, data: Data, sort: Int, completion: @escaping(Bool) -> Void) {
        var images = cardAPP.images
        NetworkManager.shared.upLoadFile(type: .image, data: data) { file in
            images[file] = sort
            let collection = images as Any
            NetworkManager.shared.updateValueElement(to: .product, document: cardAPP.id, key: "images", value: collection)
            self.updateTimeStamp()
            completion(true)
        }
    }
    //MARK: - сохранить изменения порядка сортировки
    func updateSort(to cardAPP: ProductAPP, completion: @escaping(Bool) -> Void) {
        let collection = cardAPP.images as Any
        NetworkManager.shared.updateValueElement(to: .product, document: cardAPP.id, key: "images", value: collection)
        self.updateTimeStamp()
        completion(true)
    }
    
    //MARK: - создать новую карточку
    func createNewCard(to cardAPP: ProductAPP, images: [Data], completion: @escaping(Bool) -> Void) {
        print("Создание новой карточки \(cardAPP.name)")
        let myGroup = DispatchGroup()
        let data = cardAPP.file
        var card = convertToCard(cardAPP: cardAPP)
        
        myGroup.enter()
        NetworkManager.shared.upLoadFile(to: nil, type: .data, data: data) { file in
            print("Сохранен файл \(card.name)")
            card.file = file
            myGroup.leave()
        }
        
        for index in 0..<images.count {
            myGroup.enter()
            let image = images[index]
            NetworkManager.shared.upLoadFile(type: .image, data: image) { file in
                card.images[file] = index
                myGroup.leave()
            }
        }
        
        myGroup.notify(queue: .main) {
            print("Сохранена карточка \(card.name)")
            NetworkManager.shared.upLoadProduct(to: nil, product: card) { status in
                completion(status)
            }
        }
    }
    
    //MARK: - удалить карточку
    func deleteCard(to cardAPP: ProductAPP, completion: @escaping(String, Bool) -> Void) {
        if cardAPP.countUse != 0 {
            let errorText = "Карточка используется в \(cardAPP.countUse) документах."
            let error = true
            completion(errorText,error)
        } else {
            
            NetworkManager.shared.fetchElementCollection(to: .product, doc: cardAPP.id, model: Product.self) { card in
                if let card = card {
                    NetworkManager.shared.deleteFile(type: .data, name: card.file) { status in
                        if !status {
                            print("Ошибка удаления файла \(card.file)")
                        }
                    }
                } else {
                    print("Ошибка загрузки карточки \(cardAPP.name)")
                }
            }
            
            cardAPP.images.forEach { image in
                NetworkManager.shared.deleteFile(type: .image, name: image.key) { status in
                    if !status {
                        print("Ошибка удаления файла \(image)")
                    }
                }
            }
            
            cardAPP.process.forEach { proces in
                NetworkManager.shared.deleteFile(type: .data, name: proces.key) { status in
                    if !status {
                        print("Ошибка удаления файла \(proces)")
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
    private func convertCardToCardAPP(card: Product, completion: @escaping(ProductAPP) -> Void) {
        let myGroup = DispatchGroup()
        var current = ProductAPP()
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
        NetworkManager.shared.loadFile(type: .data, name: card.file) { data in
            if let data = data {
                current.file = data
                myGroup.leave()
            } else {
                print("Ошибка загрузки файла \(card.name)")
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
            print("Сохранение обновленной карточки пользователя \(card.name)")
            completion(current)
        }
    }
    
    private func convertToCard(cardAPP: ProductAPP) -> Product {
        var card = Product()
        card.id = cardAPP.id
        card.date = cardAPP.date
        card.idUser = cardAPP.idUser
        card.idGroup = cardAPP.idGroup
        card.isActive = cardAPP.isActive
        card.countUse = cardAPP.countUse
        
        card.sort = cardAPP.sort
        card.name = cardAPP.name
        card.label = cardAPP.label
        card.images = cardAPP.images
        card.process = cardAPP.process
        return card
    }
    
    private func updateTimeStamp() {
        let collection = NetworkCollection.product.collection
        let time = Date().timeStamp()
        let system = NetworkCollection.system.collection
        NetworkManager.shared.updateValueElement(to: .system, document: system, key: collection, value: time)
    }
}
