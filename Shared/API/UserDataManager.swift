//
//  UserDataManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 04.02.2023.
//
//MARK: - методы для работы с профилем пользователя
import Foundation
import Firebase
import FirebaseFirestoreSwift

class UserDataManager {
    static let shared = UserDataManager()
    private init() {}
    //MARK: - загрузка всех карточк пользователей
    func loadCollection(completion: @escaping([UserAPP]?) -> Void) {
        NetworkManager.shared.fetchCollection(to: .user, model: UserAPP.self) { cards in
            completion(cards)
        }
    }
    
    //MARK: - загрузка карточки
    func loadCard(to doc: String?, completion: @escaping(UserAPP?) -> Void) {
        if let doc = doc {
            NetworkManager.shared.fetchElementCollection(to: .user, doc: doc, model: UserAPP.self) { card in
                completion(card)
            }
        }
    }
    
    //MARK: - обновление всех карточek коллекции
    func updateCards(to cards: [UserAPP], completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        cards.forEach { card in
            myGroup.enter()
            upLoadCard(card: card) { _ in
                NetworkManager.shared.updateTimeStamp(to: .user, doc: card.id)
                myGroup.leave()
            }
        }
        myGroup.notify(queue: .main) {
           completion(true)
        }
    }
//    
//    
//    //MARK: - обновление карточки пользователя
//    func updateUserPhoto(to userAPP: UserAPP, completion: @escaping(Bool) -> Void) {
//        let image = userAPP.image
//        if let userID = userAPP.id {
//            print("Обновление фото пользователя \(userAPP.name) \(userID)")
//            FileAppManager.shared.loadFileData(to: image, type: .assets) { data in
//                if let data = data {
//                    NetworkManager.shared.upLoadFile(to: image, type: .image, data: data) { _ in
//                        print("Сохранен файл image \(userAPP.name)")
//                        let image = image as Any
//                        NetworkManager.shared.updateValueElement(to: .user, document: userID, key: "image", value: image)
//                        completion(true)
//                    }
//                } else {
//                    completion(false)
//                }
//            }
//        } else {
//            completion(false)
//        }
//    }
    
    //MARK: - создать новую карточку
    func createCard(to card: UserAPP, completion: @escaping(Bool) -> Void) {
        let myGroup = DispatchGroup()
        if !card.image.isEmpty {
            myGroup.enter()
            saveFile(to: card.image, doc: card.id) { _ in
                myGroup.leave()
            }
        }
        myGroup.enter()
        upLoadCard(card: card) { _ in
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            completion(true)
        }
    }
    
    //MARK: - методы работы с пользователем USER
    // сохранение пользователя
    func upLoadCard(card: UserAPP?, completion: @escaping (Bool) -> Void) {
        let collection = NetworkCollection.user.collection
        if let card = card {
            var id = card.id
            if card.id.isEmpty {
                id = Firestore.firestore().collection(collection).document().documentID
            }
            let data = ["id" : id,
                        "date" : card.date,
                        "idUser" : card.idUser,
                        "isActive" : card.isActive,
                        
                        "email" : card.email,
                        "phone" : card.phone,
                        "name" : card.name,
                        "surname" : card.surname,
                        
                        
                        "image" : card.image,
                        "role" : card.role,
                        "roles" : card.roles,
                        "stages" : card.stages,
                        
                        "profile" : card.profile ] as [String : Any]
            NetworkManager.shared.upLoadElementCollection(to: .user, name: id, data: data) { status in
                completion(status)
            }
        } else {
            completion(false)
        }
    }
}

//MARK: - file metods
extension UserDataManager {
    //MARK: - сохранение файла
    func saveFile(to file: String?, doc: String, completion: @escaping(Bool) -> Void)  {
        if let file = file {
            FileAppManager.shared.loadFileData(to: file, type: .assets) { data in
                if let data = data {
                    NetworkManager.shared.upLoadFile(to: file, type: .image, data: data) { _ in
                        NetworkManager.shared.updateTimeStamp(to: .user, doc: doc)
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    //MARK: - загрузка файла
    func loadFile(to file: String, completion: @escaping(Data?) -> Void) {
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
//MARK: -  удаление файла
    func deleteFile(to file: String?, doc: String, completion: @escaping(Bool) -> Void)  {
        if let file = file {
            FileAppManager.shared.deleteFile(to: file, type: .assets)
            NetworkManager.shared.deleteFile(type: .image, name: file) { status in
                NetworkManager.shared.updateTimeStamp(to: .user, doc: doc)
                completion(status)
            }
        }
    }
}
