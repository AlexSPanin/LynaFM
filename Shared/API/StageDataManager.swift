//
//  StageDataManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.02.2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class StageDataManager {
    static let shared = StageDataManager()
    private init() {}
    
    //MARK: - загрузка всех карточк
    func loadCollection(completion: @escaping([ProductionStage]?) -> Void) {
        NetworkManager.shared.fetchCollection(to: .stage, model: ProductionStage.self) { cards in
            if let cards = cards {
                completion(cards.sorted(by: {$0.sort < $1.sort}))
            } else {
                print("Ошибка: сбой обнавления коллекции.")
                completion(nil)
            }
        }
    }
    
    //MARK: - загрузка карточки
    func loadCard(to id: String?, completion: @escaping(ProductionStage?) -> Void) {
        if let id = id {
            NetworkManager.shared.fetchElementCollection(to: .stage, doc: id, model: ProductionStage.self) { card in
                completion(card)
            }
        }
    }
    
    //MARK: - обновление всех карточek
    func updateCards(to cards: [ProductionStage], completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        cards.forEach { card in
            myGroup.enter()
            upLoadStage(stage: card) { _ in
                NetworkManager.shared.updateTimeStamp(to: .stage, doc: card.id, sub: .elements)
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
           completion(true)
        }
    }
    
    
    //MARK: - обновление карточки
    func updateCard(to card: ProductionStage, completion: @escaping(Bool) -> Void) {
        upLoadStage(stage: card) { status in
            NetworkManager.shared.updateTimeStamp(to: .stage, doc: card.id, sub: .elements)
            completion(status)
        }
    }
    
    //MARK: - создать новую карточку
    func createCard(to card: ProductionStage, completion: @escaping(Bool) -> Void) {
        upLoadStage(stage: card) { status in
            completion(status)
        }
    }
    
    //MARK: - удалить карточку
    func deleteCard(to card: ProductionStage, completion: @escaping(Bool) -> Void) {
        if card.countUse == 0 {
            NetworkManager.shared.deleteElement(to: .stage, document: card.id) { status in
                NetworkManager.shared.updateTimeStamp(to: .stage, doc: card.id, sub: .elements)
                completion(status)
            }
        }
    }
    
    //MARK: - методы работы с этапами производства
    // сохранение этапа производства
    func upLoadStage(stage: ProductionStage?, completion: @escaping (Bool) -> Void) {
        let collection = NetworkCollection.stage.collection
        if let stage = stage {
            var id = stage.id
            if stage.id.isEmpty {
                id = Firestore.firestore().collection(collection).document().documentID
            }
            let data = ["id" : id,
                        "date" : stage.date,
                        "idUser" : stage.idUser,
                        "isActive" : stage.isActive,
                        "countUse" : stage.countUse,
                        
                        "sort" : stage.sort,
                        "name" : stage.name,
                        "label" : stage.label] as [String : Any]
            NetworkManager.shared.upLoadElementCollection(to: .stage, name: id, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }
}
