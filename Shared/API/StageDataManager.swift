//
//  StageDataManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.02.2023.
//

import Foundation

class StageDataManager {
    static let shared = StageDataManager()
    private init() {}
    
    //MARK: - загрузка всех карточк
    func loadCollection(completion: @escaping(Result<[ProductionStage], NetworkError>) -> Void) {
        NetworkManager.shared.fetchFullCollection(to: .stage, model: ProductionStage.self) { result in
            switch result {
            case .success(let cards):
                print("Коллекция из сети загружена")
                completion(.success(cards))
            case .failure(_):
                print("Ошибка: сбой обнавления коллекции.")
                completion(.failure(.fetchCollection))
            }
        }
    }
    
    //MARK: - загрузка карточки
    func loadCard(to id: String?, completion: @escaping(Result<ProductionStage, NetworkError>) -> Void) {
        if let id = id {
            NetworkManager.shared.fetchElementCollection(to: .stage, doc: id, model: ProductionStage.self) { result in
                switch result {
                case .success(let card):
                        completion(.success(card))
                case .failure(_):
                    print("Ошибка загрузки карточки из сети \(id)")
                    completion(.failure(.fetchUser))
                }
            }
        }
    }
    
    //MARK: - обновление карточки
    func updateCard(to cardAPP: ProductionStage, completion: @escaping(Bool) -> Void) {
        NetworkManager.shared.upLoadStage(to: cardAPP.id, stage: cardAPP) { status in
            completion(status)
        }
    }
    
    //MARK: - создать новую карточку
    func createNewCard(to cardAPP: ProductionStage, completion: @escaping(Bool) -> Void) {
        NetworkManager.shared.upLoadStage(to: nil, stage: cardAPP) { status in
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
    private func updateTimeStamp() {
        let collection = NetworkCollection.stage.collection
        let time = Date().timeStamp()
        let system = NetworkCollection.system.collection
        NetworkManager.shared.updateValueElement(to: .system, document: system, key: collection, value: time)
    }
}
