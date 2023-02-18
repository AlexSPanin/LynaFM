//
//  StoradgeManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation

class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
    // MARK: - проверка и установка Bool ключей
    func checkKey(type: TypeKey) -> Bool {
        return userDefaults.bool(forKey: type.key)
    }
    func settingKey(to type: TypeKey, key: Bool) {
        userDefaults.set(key, forKey: type.key)
    }
    
    // MARK: - запись и чтение по ключу и по типу модели (для кодирования)
    func load<T: Decodable>(type: TypeKey, model: T.Type, completion: @escaping(T?) -> Void) {
        if let data = userDefaults.object(forKey: type.key) as? Data {
            do {
                let decoder = try JSONDecoder().decode(T.self, from: data)
                completion(decoder)
            } catch {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    func save<T: Encodable>(type: TypeKey, model: T.Type, collection: Any ) {
  //          print("Начало сохранения коллекции в память \(type.key)")
        if let collection = collection as? T {
            do {
                let data = try JSONEncoder().encode(collection)
                userDefaults.set(data, forKey: type.key)
            } catch {
                print("Ошибка сохранения в память \(type.key)")
            }
        }
    }
    
    func remove(type: TypeKey) {
        userDefaults.removeObject(forKey: type.key)
    }
}


