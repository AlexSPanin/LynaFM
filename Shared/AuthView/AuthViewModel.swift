//
//  AuthViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation

class AuthViewModel: ObservableObject {
    
    // переменные полей пользователя для входа по паролю
    @Published var email = ""
    @Published var passwordEnter: String = ""
    // признак проверки входа по паролю
    @Published var logIn = false {
        didSet {
            checkLogIn()
        }
    }
    // признак окончания загрузки пользователя
    @Published var isFinishLoadUser = false
    // признак окна восстановления
    @Published var isShowRepair = false
    // признак корректной версии программы
    @Published var isVersion = false
    
    // отработка экрана ошибки
    @Published var errorText = ""
    @Published var errorOccured = false
    
    var user: User?
    
    init() {
        print("START: AuthViewModel")
        checkVersion()
        
    }
    deinit {
        print("CLOSE: AuthViewModel")
    }
    private func checkVersion() {
        NetworkManager.shared.fetchVersion { result in
            switch result {
            case .success(let ver):
                if ver == version {
                    self.isVersion = true
                } else {
                    self.errorText = NotificationMessage.version.text
                    self.errorOccured = true
                }
            case .failure(_):
                print("ERROR: fetchVersion")
            }
        }
    }
    
    
    
    
    // проверка входа по паролю
    private func checkLogIn() {
        print("LoginUserViewModel: Начало входа по паролю")
        if email.isEmpty || passwordEnter.isEmpty {
            errorText = "Все поля должны\nбыть заполнены"
            errorOccured.toggle()
            return
        } else {
           
            AuthUserManager.shared.login(email: email, password: passwordEnter) { text, error in
                if error {
                    self.errorText = text
                    self.errorOccured = error
                    self.passwordEnter = ""
                    self.isFinishLoadUser = false
                    return
                } else {
                    self.isFinishLoadUser = false
                    if let name = AuthUserManager.shared.userSession?.uid {
                        NetworkManager.shared.loadUser(name: name) { result in
                            switch result {
                            case .success(let user):
                                self.user = user
                            case .failure(_):
                                print("надо сформировать новый профиль")
                            }
                        }
                    }
                }
            }
        }
    }
}
