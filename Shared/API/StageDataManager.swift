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
        NetworkManager.shared.fetchFullCollection(to: .stage, model: ProductionStage.self) { cards in
            if let cards = cards {
                completion(cards.sorted(by: {$0.sort < $1.sort}))
            } else {
                print("Ошибка: сбой обнавления коллекции.")
                completion(nil)
            }
        }
    }
    
    //MARK: - загрузка карточки
    func loadCard(to id: String?, completion: @escaping(Result<ProductionStage, NetworkError>) -> Void) {
        if let id = id {
            NetworkManager.shared.fetchElementCollection(to: .stage, doc: id, model: ProductionStage.self) { card in
                if let card = card {
                        completion(.success(card))
                } else {
                    print("Ошибка загрузки карточки из сети \(id)")
                    completion(.failure(.fetchUser))
                }
            }
        }
    }
    
    //MARK: - обновление всех карточek
    func updateCards(to cards: [ProductionStage], completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        cards.forEach { card in
            myGroup.enter()
            upLoadStage(stage: card) { _ in
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
           completion(true)
        }
    }
    
    
    //MARK: - обновление карточки
    func updateCard(to cardAPP: ProductionStage, completion: @escaping(Bool) -> Void) {
        upLoadStage(stage: cardAPP) { status in
            completion(status)
        }
    }
    
    //MARK: - создать новую карточку
    func createNewCard(to cardAPP: ProductionStage, completion: @escaping(Bool) -> Void) {
        upLoadStage(stage: cardAPP) { status in
            completion(status)
        }
    }
    
    //MARK: - удалить карточку
    func deleteCard(to cardAPP: ProductionStage, completion: @escaping(String, Bool) -> Void) {
        if cardAPP.countUse != 0 {
            let errorText = "Карточка используется в \(cardAPP.countUse) документах."
            let error = true
            completion(errorText,error)
        } else {
            NetworkManager.shared.deleteElement(to: .stage, document: cardAPP.id) { status in
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
