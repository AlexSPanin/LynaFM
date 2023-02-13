//
//  GroupDataManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.02.2023.
//

import Foundation

class GroupDataManager {
    static let shared = GroupDataManager()
    private init() {}
    
    //MARK: - загрузка всех карточк
    func loadCollection(completion: @escaping(Result<[GroupAPP], NetworkError>) -> Void) {
        let myGroup = DispatchGroup()
        NetworkManager.shared.fetchCollection(to: .group, model: Group.self) { cards in
            if let cards = cards {
                print("Коллекция из сети загружена")
                var cardsAPP = [GroupAPP]()
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
    func loadCard(to id: String?, completion: @escaping(Result<GroupAPP, NetworkError>) -> Void) {
        if let id = id {
            NetworkManager.shared.fetchElementCollection(to: .group, doc: id, model: Group.self) { card in
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
    func updateCard(to cardAPP: GroupAPP, completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        let cardID = cardAPP.id
        print("Обновление карточки пользователя \(cardAPP.name)")
        NetworkManager.shared.fetchElementCollection(to: .group, doc: cardID, model: Group.self) { card in
            if let card = card {
                myGroup.enter()
                NetworkManager.shared.upLoadFile(to: card.file, type: .group, data: cardAPP.file) { _ in
                    print("Сохранен файл userData \(cardAPP.name)")
                    myGroup.leave()
                }
                var cardExport = self.convertToCard(cardAPP: cardAPP)
                cardExport.file = card.file
                myGroup.notify(queue: .main) {
                    print("Сохранение обновленной карточки пользователя \(cardAPP.name)")
                    NetworkManager.shared.upLoadGroup (to: cardID, group: cardExport) { status in
                        completion(status)
                    }
                }
            } else {
                print("Ошибка загрузки карточки пользователя из сети \(cardAPP.name)")
                completion(false)
            }
        }
    }
    
    //MARK: - создать новую карточку
    func createNewCard(to cardAPP: GroupAPP, completion: @escaping(Bool) -> Void) {
        print("Создание новой карточки \(cardAPP.name)")
        let myGroup = DispatchGroup()
        let data = cardAPP.file
        var card = convertToCard(cardAPP: cardAPP)

        myGroup.enter()
        NetworkManager.shared.upLoadFile(to: nil, type: .group, data: data) { file in
            print("Сохранен файл \(card.name)")
            card.file = file
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            print("Сохранена карточка \(card.name)")
            NetworkManager.shared.upLoadGroup(to: nil, group: card) { status in
                completion(status)
            }
        }
    }
    
    //MARK: - удалить карточку
    func deleteCard(to cardAPP: GroupAPP, completion: @escaping(String, Bool) -> Void) {
        if cardAPP.countUse != 0 {
            let errorText = "Карточка используется в \(cardAPP.countUse) документах."
            let error = true
            completion(errorText,error)
        } else {
            NetworkManager.shared.fetchElementCollection(to: .group, doc: cardAPP.id, model: Group.self) { card in
                if let card = card {
                    NetworkManager.shared.deleteFile(type: .group, name: card.file) { status in
                        if !status {
                            print("Ошибка удаления файла \(card.file)")
                        }
                    }
                } else {
                    print("Ошибка загрузки карточки \(cardAPP.name)")
                }
            }
            NetworkManager.shared.deleteElement(to: .group, document: cardAPP.id) { status in
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
    private func convertCardToCardAPP(card: Group, completion: @escaping(GroupAPP) -> Void) {
        let myGroup = DispatchGroup()
        var current = GroupAPP()
        current.id = card.id
        current.date = card.date
        current.idUser = card.idUser
        current.idType = card.idType
        current.isActive = card.isActive
        current.countUse = card.countUse
        
        current.sort = card.sort
        current.name = card.name
        current.label = card.label
        
        myGroup.enter()
        NetworkManager.shared.loadFile(type: .group, name: card.file) { result in
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
    
    private func convertToCard(cardAPP: GroupAPP) -> Group {
        var card = Group()
        card.id = cardAPP.id
        card.date = cardAPP.date
        card.idUser = cardAPP.idUser
        card.idType = cardAPP.idType
        card.isActive = cardAPP.isActive
        card.countUse = cardAPP.countUse
        
        card.sort = cardAPP.sort
        card.name = cardAPP.name
        card.label = cardAPP.label
        return card
    }
    
    private func updateTimeStamp() {
        let collection = NetworkCollection.group.collection
        let time = Date().timeStamp()
        let system = NetworkCollection.system.collection
        NetworkManager.shared.updateValueElement(to: .system, document: system, key: collection, value: time)
    }
}
