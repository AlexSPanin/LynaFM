//
//  ParametrDataManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.02.2023.
//

import Foundation

class ParameterDataManager {
    static let shared = ParameterDataManager()
    private init() {}
    
    //MARK: - загрузка всех карточк
    func loadCollection(completion: @escaping(Result<[ProductParameterAPP], NetworkError>) -> Void) {
        let myGroup = DispatchGroup()
        NetworkManager.shared.fetchFullCollection(to: .stage, model: ProductParameter.self) { result in
            switch result {
            case .success(let cards):
                print("Коллекция из сети загружена")
                var cardsAPP = [ProductParameterAPP]()
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
    func loadCard(to id: String?, completion: @escaping(Result<ProductParameterAPP, NetworkError>) -> Void) {
        if let id = id {
            NetworkManager.shared.fetchElementCollection(to: .parameter, doc: id, model: ProductParameter.self) { result in
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
    func updateCard(to cardAPP: ProductParameterAPP, completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        let cardID = cardAPP.id
        print("Обновление карточки пользователя \(cardAPP.name)")
        NetworkManager.shared.fetchElementCollection(to: .parameter, doc: cardID, model: ProductParameter.self) { result in
            switch result {
            case .success(let card):
                myGroup.enter()
                NetworkManager.shared.upLoadFile(to: card.file, type: .parameter, data: cardAPP.file) { _ in
                    print("Сохранен файл userData \(cardAPP.name)")
                    myGroup.leave()
                }
                var cardExport = self.convertToCard(cardAPP: cardAPP)
                cardExport.file = card.file
                myGroup.notify(queue: .main) {
                    print("Сохранение обновленной карточки пользователя \(cardAPP.name)")
                    NetworkManager.shared.upLoadParameter (to: cardID, param: cardExport) { status in
                        completion(status)
                    }
                }
            case .failure(_):
                print("Ошибка загрузки карточки пользователя из сети \(cardAPP.name)")
                completion(false)
            }
        }
    }
    
    //MARK: - создать новую карточку
    func createNewCard(to cardAPP: ProductParameterAPP, completion: @escaping(Bool) -> Void) {
        print("Создание новой карточки \(cardAPP.name)")
        let myGroup = DispatchGroup()
        let data = cardAPP.file
        var card = convertToCard(cardAPP: cardAPP)

        myGroup.enter()
        NetworkManager.shared.upLoadFile(to: nil, type: .parameter, data: data) { file in
            print("Сохранен файл \(card.name)")
            card.file = file
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            print("Сохранена карточка \(card.name)")
            NetworkManager.shared.upLoadParameter(to: nil, param: card) { status in
                completion(status)
            }
        }
    }
    
    //MARK: - удалить карточку
    func deleteCard(to cardAPP: ProductParameterAPP, completion: @escaping(String, Bool) -> Void) {
        if cardAPP.countUse != 0 {
            let errorText = "Карточка используется в \(cardAPP.countUse) документах."
            let error = true
            completion(errorText,error)
        } else {
            NetworkManager.shared.deleteElement(to: .parameter, document: cardAPP.id) { status in
                if status {
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
    private func convertCardToCardAPP(card: ProductParameter, completion: @escaping(ProductParameterAPP) -> Void) {
        let myGroup = DispatchGroup()
        var current = ProductParameterAPP()
        current.id = card.id
        current.date = card.date
        current.idUser = card.idUser
        current.isActive = card.isActive
        current.countUse = card.countUse
        
        current.sort = card.sort
        current.name = card.name
        current.label = card.label
        
        myGroup.enter()
        NetworkManager.shared.loadFile(type: .parameter, name: card.file) { result in
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
    
    private func convertToCard(cardAPP: ProductParameterAPP) -> ProductParameter {
        var card = ProductParameter()
        card.id = cardAPP.id
        card.date = cardAPP.date
        card.idUser = cardAPP.idUser
        card.isActive = cardAPP.isActive
        card.countUse = cardAPP.countUse
        
        card.sort = cardAPP.sort
        card.name = cardAPP.name
        card.label = cardAPP.label
        return card
    }

}
