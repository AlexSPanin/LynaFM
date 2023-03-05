//
//  NavigationViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import Foundation

enum Navigation {
    case load, auth, admin, order, stage
    case error
}

class NavigationViewModel: ObservableObject {
    
    @Published var showView = Navigation.load
    @Published var title: String = "NavigationViewModel"
    
    // системные файлы из облака и локальный
    @Published var systemStorage: SystemApp?
    var systemServer: SystemApp?
    
    init() {
        print("START: NavigationViewModel")
        if AuthUserManager.shared.currentUserID() != nil {
        fetchSystemApp()
        }
    }
    deinit {
        print("CLOSE: NavigationViewModel")
    }
    
    // получаем системный файл из облака и локально
    private func fetchSystemApp(){
        print("fetchSystemApp(): NavigationViewModel")
        StorageManager.shared.load(type: .system, model: SystemApp.self) { storage in
            if let storage = storage {
                self.systemStorage = storage
                self.systemStorage?.ver = version
            }
        }
        
        NetworkManager.shared.fetchElementCollection(to: .system, doc: "system", model: SystemApp.self) { network in
            if let network = network {
                self.systemServer = network
                self.checkVersionApp()
            } else {
                self.title = "Проверьте подключение к сети Интернет"
                self.showView = .error
            }
        }
    }
    
    // MARK: - проверяем версию программы
    private func checkVersionApp() {
        if let systemStorage = systemStorage {
            if let systemServer = systemServer, systemServer.ver == systemStorage.ver {
                showView = .auth
            } else {
                title = "Закройте приложение.\nСкачайте и установите\nновую версию!"
                showView = .error
            }
        } else {
            if let systemServer = systemServer {
                systemStorage = systemServer
                let collection = systemServer as Any
                StorageManager.shared.save(type: .system, model: SystemApp.self, collection: collection)
                showView = .auth
            } else {
                title = "Закройте приложение.\nОбратитесь в Тех. попддержку"
                showView = .error
            }
        }
    }
}
