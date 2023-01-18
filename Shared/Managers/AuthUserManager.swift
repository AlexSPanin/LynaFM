//
//  AuthUserManager.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation
import Firebase

class AuthUserManager {
    
    var userSession: FirebaseAuth.User?
    
    static let shared = AuthUserManager()
    
    init() { print("AuthUserViewModel: Init") }
    
    deinit { print("AuthUserViewModel: DeInit") }
    
    func updateUserSession() -> Bool {
        //        print("AuthUserViewModel: Проверка интернет сесии Пользователя")
        userSession = Auth.auth().currentUser
        print("AuthUserViewModel:  userSession \(userSession?.uid ?? "Не авторизован")")
        return userSession != nil
    }
    
    //MARK: - методы для работы с пользователями в базе данных
    
    // Регистрация по паролю
    func registrationPassword(email: String, password: String, completion: @escaping (String, Bool) -> Void) {
              print("AuthUserViewModel: Регистрация по паролю")
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                var errorText = "Ошибка регистрации:\nКод ошибки \(error._code)"
                let errorOccured = true
                switch error._code {
                case 17007:
                    errorText = "Ошибка регистрации:\nАккаунт уже существует."
                default:
                    break
                }
                completion(errorText, errorOccured)
                return
            }
            guard let user = result?.user else { return }
            self.userSession = user
            completion("", false)
        }
    }
    
    // Вход по паролю
    func login(email: String, password: String, completion: @escaping (String, Bool) -> Void) {
        print("AuthUserViewModel: Вход по паролю")
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                let errorOccured = true
                var errorText = "Ошибка авторизации:\nКод ошибки \(error._code)"
                switch error._code {
                case 17009:
                    errorText = "Ошибка авторизации:\nНе корректный пароль"
                case 17011:
                    errorText = "Ошибка авторизации:\nЛогин не существует"
                default:
                    break
                }
                completion(errorText, errorOccured)
                return
            }
            guard let user = result?.user else { return }
            self.userSession = user
            completion("", false)
        }
    }
    
    // Отправка ссылки на восстановление пароля
    func sendLinkForPasswordReset(with email: String, completion: @escaping (String, Bool) -> ()) {
        print("AuthUserViewModel: Отправка ссылки на восстановление")
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                let errorText = "Данный аккаунт не зарегистрирован.\n Код ошибки \(error._code)"
                let errorOccured = true
                completion(errorText, errorOccured)
                return
            }
            
            let errorText = "Проверьте свой почтовый ящик."
            let errorOccured = false
            completion(errorText, errorOccured)
            
        }
    }
    
    // выход из учетной записи
    func exitingUser(completion: @escaping(String, Bool) -> Void) {
        print("AuthUserViewModel: Выход из учетной записи")
        let auth = Auth.auth()
        do {
            try auth.signOut()
            completion("", false)
        } catch {
            let errorText = "Ошибка выхода из системы"
            let errorOccured = true
            completion(errorText, errorOccured)
        }
    }
    
    
    // удаление пользователя по подтверждению пароля и логина
    func deleteUser(email: String, password: String, completion: @escaping(String, Bool) -> Void) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user?.reauthenticate(with: credential) { _, reAuth in
            if let reAuth = reAuth {
                var errorText = "Ошибка аутентификации:\nКод ошибки \(reAuth._code)"
                let errorOccured = true
                switch reAuth._code {
                case 17009:
                    errorText = "Ошибка аутентификации:\nНеверный пароль или логин."
                case 17024:
                    errorText = "Ошибка аутентификации.\nНеверный логин или пароль."
                default:
                    break
                }
                completion(errorText, errorOccured)
            } else {
                user?.delete { error in
                    if error != nil {
                        let errorText = "Ошибка при удалении."
                        let errorOccured = true
                        completion(errorText, errorOccured)
                    } else {
                        completion("", false)
                    }
                }
            }
        }
    }
}
    
