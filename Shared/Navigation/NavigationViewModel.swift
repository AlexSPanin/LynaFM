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
    @Published var labelBase: String = ""
    
    // системные файлы из облака и локальный
    var systemStorage: SystemApp?
    var systemServer: SystemApp?
    // словарь чек лист
    var checkList: [NetworkCollection: CheckLine] = [:]
    // признак проверки чек листа
    var isCheck: Bool = false {
        didSet {
            let check = checkList.contains(where: {$0.value.isLoading == true })
            print("checkList enable True: \(check)")
            isFinishLoad = !check
        }
    }
    // признак окончания загрузки
    var isFinishLoad: Bool = false {
        didSet {
            if isFinishLoad {
                view = .auth
            }
        }
    }
    // нет интернета - нет возможности загрузить чек лист
    var notNetwork: Bool = false
    
    
    init() {
        print("START: NavigationViewModel")
        fetchSystemApp()
        checkDataBase()
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
                self.notNetwork = true
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
        }
    }
    
    private func checkDataBase() {
        let myGroup = DispatchGroup()
        myGroup.enter()
        checkUser {
            self.isCheck.toggle()
            myGroup.leave()
        }
        
        myGroup.notify(queue: .main) {
            self.isCheck.toggle()
        }
        
    }
    
    private func checkUser(completion: @escaping() -> Void) {
        // проверяем базу категорий
        if let isLoading = checkList[.user]?.isLoading, isLoading {
            labelBase = "Loading ProductPropriety Base"
            NetworkManager.shared.fetchFullCollection(to: .user, model: User.self) { result in
                switch result {
                case .success(let collection):
                    print("Collection Users is Enable", collection)
                    let collection = collection as Any
                    StorageManager.shared.save(type: .users, model: [User].self, collection: collection)
                    self.checkList[.user] = CheckLine(app: self.systemServer?.user, server: self.systemServer?.user)
                    completion()
                case .failure(_):
                    // если не смогли загрузить то пытаемся проверить локальную, если нет то ошибка
                    print("ERROR: network fetch ProductPropriety")
                    StorageManager.shared.load(type: .users, model: [User].self) { result in
                        switch result {
                        case .success(_):
                            self.checkList[.user] = CheckLine(app: self.systemStorage?.user, server: self.systemStorage?.user)
                            completion()
                        case .failure(_):
                            print("ERROR: storage load ProductPropriety")
                            self.view = .error
                        }
                    }
                }
            }
        } else {
            completion()
        }
    }
}
