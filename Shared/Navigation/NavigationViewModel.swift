//
//  NavigationViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import Foundation

enum Navigation {
    case load, auth, role
    case error, version
}

// структура для проверки
struct CheckLine: Codable {
    var app: String?
    var server: String?
    var isLoading: Bool {
        if let app = app, let server = server {
           return !(app == server)
        } else {
            return true
        }
    }
}

class NavigationViewModel: ObservableObject {
    
    @Published var view = Navigation.load
    @Published var label: String = ""
    @Published var checkList: [NetworkCollection: CheckLine] = [:]
    
    // системные файлы из облака и локальный
    var systemStorage: SystemApp?
    var systemServer: SystemApp?
    
    init() {
        print("START: NavigationViewModel")
        fetchSystemApp()
    }
    deinit {
        print("CLOSE: NavigationViewModel")
    }
    
    // получаем системный файл из облака и локально
    private func fetchSystemApp(){
        StorageManager.shared.load(type: .system, model: SystemApp.self) { result in
            switch result {
            case .success(let storage):
                self.systemStorage = storage
                self.systemStorage?.ver = version
            case .failure(_):
                print("ERROR: loadSystemApp Storge")
            }
        }
 
        if let systemStorage = systemStorage {
            print("SystemStorage: \(systemStorage)")
        }
        
        NetworkManager.shared.fetchElementCollection(to: .system, doc: "system", model: SystemApp.self) { result in
            switch result {
            case .success(let network):
                self.systemServer = network
                self.checkVersionApp()
            case .failure(_):
                print("ERROR: fetchSystemAppNetwork")
                self.label = "ERROR: Not Network"
                self.view = .error
            }
        }
    }
    
    // MARK: - проверяем версию программы
    private func checkVersionApp() {
        if let systemServer = systemServer {
            if let systemStorage = systemStorage {
                print("systemStorage - enable")
                checkList[.system] = CheckLine(app: systemStorage.ver, server: systemServer.ver)
                checkList[.user] = CheckLine(app: systemStorage.user, server: systemServer.user)
                checkList[.product] = CheckLine(app: systemStorage.product, server: systemServer.product)
                checkList[.material] = CheckLine(app: systemStorage.material, server: systemServer.material)
                checkList[.bundle] = CheckLine(app: systemStorage.bundle, server: systemServer.bundle)
                checkList[.group] = CheckLine(app: systemStorage.group, server: systemServer.group)
                checkList[.parameter] = CheckLine(app: systemStorage.parameter, server: systemServer.parameter)
                checkList[.stage] = CheckLine(app: systemStorage.stage, server: systemServer.stage)
            } else {
                print("systemStorage - is enable")
                checkList[.system] = CheckLine(app: version, server: systemServer.ver)
                checkList[.user] = CheckLine(app: "", server: systemServer.user)
                checkList[.product] = CheckLine(app: "", server: systemServer.product)
                checkList[.material] = CheckLine(app: "", server: systemServer.material)
                checkList[.bundle] = CheckLine(app: "", server: systemServer.bundle)
                checkList[.group] = CheckLine(app: "", server: systemServer.group)
                checkList[.parameter] = CheckLine(app: "", server: systemServer.parameter)
                checkList[.stage] = CheckLine(app: "", server: systemServer.stage)
                StorageManager.shared.save(type: .system, model: SystemApp.self, collection: systemServer)
            }
        }
        if let ver = checkList[.system]?.isLoading, ver {
            view = .version
        } else {
            view = .auth
        }
    }
}
