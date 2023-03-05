//
//  GroupViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.02.2023.
//

import SwiftUI

class GroupAdminViewModel: ObservableObject {
    //MARK: -  общие переменные
    @Published var label = "Справочник товарных групп"
    @Published var cards = [Group]()
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var type: String = ""
    
    @Published var card: Group? {
        didSet {
            if let card = card {
                index = cards.firstIndex(where: { card.id == $0.id } )
            }
        }
    }
    @Published var index: Int?
    
    @Published var nameUser = ""
    @Published var date = ""
    
    //MARK: - отработка загрузки изображения
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var isImagePickerDisplay = false
    @Published var image: Data?
    @Published var isDeleteImage = false {
        didSet {
            image = nil
            if let card = index {
            cards[card].image = ""
            }
        }
    }
    //MARK: - переменные для работе с карточками коллекций
    //MARK: - признаки запуска методов
    @Published var isAdd = false {
        didSet {
            add()
        }
    }
    @Published var isEdit = false {
        didSet {
            edit(to: index)
        }
    }
    @Published var isMove = false {
        didSet {
            saveMoving()
        }
    }
    //MARK: - признаки показа окон
    @Published var showTabCollection = false
    @Published var showAdd = false {
        didSet {
            if showAdd {
                label = "Добавить новую группу."
                card = nil
                image = nil
                date = Date().timeStamp().croppingLastRigthSimbols(" ")
                isActive = true
                name = ""
                description = ""
                type = ""
            } else {
                label = "Справочник товарных групп"
            }
        }
    }
    @Published var showEdit = false {
        didSet {
            if showEdit {
                if let card = index {
                    label = "Редактировать: \(name)"
                    date = Date().timeStamp().croppingLastRigthSimbols(" ")
                    isActive = cards[card].isActive
                    name = cards[card].name
                    description = cards[card].label
                    type = cards[card].type
                    loadImage(to: card) { data in
                        self.image = data
                    }
                }
            } else {
                label = "Справочник товарных групп"
            }
        }
    }
    
    //MARK: - признаки проверок состояния
    @Published var isChange = false
    @Published var isActive = false {
        didSet {
            if let card = index {
                if isActive != cards[card].isActive {
                checkActive(to: card)
                }
            }
        }
    }
    //MARK: -  отработка экрана ошибки
    @Published var errorText = ""
    @Published var errorOccured = false
    @Published var typeNote = false
    
    var idUser = ""
    
    init() {
        print("START: GroupAdminViewModel")
        StorageManager.shared.load(type: .user, model: UserAPP.self) { card in
            if let card = card {
                self.idUser = card.id
                self.nameUser = card.name + " " + card.surname
            }
        }
        fethNetwork()
    }
    deinit {
        print("CLOSE: GroupAdminViewModel")
    }
    //MARK: - создание карточки коллекции
    private func add() {
        print("Создание карточки коллекции")
        let index = cards.count
        var group = Group()
        group.id = UUID().uuidString
        group.idUser = idUser
        group.date = Date().timeStamp()
        group.sort = cards.filter({$0.type == type}).count + 1
        group.name = name
        group.label = description
        group.type = type
        cards.append(group)
        self.index = index
        saveImage(to: index, file: nil, data: image)
        GroupDataManager.shared.createCard(to: group) { _ in
            self.showAdd.toggle()
        }
    }
    
    
    //MARK: - редактирование карточки коллекции
    private func edit(to card: Int?) {
        print("Редактирование карточки коллекции")
        if isChange {
            if let card = card {
                cards[card].date = Date().timeStamp()
                cards[card].idUser = idUser
                cards[card].name = name
                cards[card].label = description
                let file: String? = (cards[card].image.isEmpty ? nil : cards[card].image)
                saveImage(to: card, file: file, data: image)
                GroupDataManager.shared.updateCard(to: cards[card]) { _ in
                    self.isChange = false
                    self.showEdit.toggle()
                }
            }
        } else {
            showEdit.toggle()
        }
    }
    
    //MARK: -  получение актуального массива  из сети
    private func fethNetwork() {
        print("Получение коллекции карточек из сети")
        GroupDataManager.shared.loadCollection { groups in
            if let groups = groups {
                if groups.isEmpty {
                    self.showTabCollection.toggle()
                } else {
                    self.cards = groups.sorted(by: {$0.sort < $1.sort})
                    self.showTabCollection.toggle()
                }
            }
        }
    }
    
    //MARK: - методы переключения и проверки активного статуса карточки коллекции
    private func checkActive(to card: Int) {
        print("проверка на Деактивация карточки")
        let countUse = cards[card].countUse
        if !isActive {
            if countUse != 0 {
                errorText = "ОШИБКА!\nКарточка используется в\n других документах!"
                errorOccured = true
                typeNote = false
            } else {
                errorText = "Предупреждение!\nПодтвердите деактивацию картоки!"
                errorOccured = true
                typeNote = true
            }
        } else {
            inActive(to: card)
        }
    }
    
    func inActive(to card: Int?) {
        if let card = card {
            cards[card].isActive.toggle()
            isChange = true
        }
    }
    
    //MARK: - загрузка или сохранение файлов изображения
    func loadFileImage(to url: URL) -> UIImage {
        var image = UIImage()
        FileAppManager.shared.loadFileURL(to: url) { data in
            if let data = data, let uiImage = UIImage(data: data) {
               image = uiImage
            }
        }
        return image
    }
    
    private func loadImage(to card: Int, completion: @escaping(Data?) -> Void) {
        if cards[card].image.isEmpty {
            completion(nil)
        } else {
            let file = cards[card].image
            GroupDataManager.shared.loadFileImage(to: file) { data in
                completion(data)
            }
        }
    }
    
    //MARK: -  записывает файл изображения, если имя nil создает новую запись
    private func saveImage(to card: Int, file: String?, data: Data?) {
        if let data = data {
            let doc = cards[card].id
            var nameFile = UUID().uuidString  + ".png"
            if let file = file {
                nameFile = file
            } else {
                cards[card].image.append(nameFile)
            }
            FileAppManager.shared.saveFileData(to: nameFile, type: .assets, data: data)
            GroupDataManager.shared.saveFileImage(to: nameFile, doc: doc) { _ in
            }
        }
    }
    //MARK: -  методы по сортировке коллекций
    func move(from source: IndexSet, to dest: Int) {
        print(source)
        print(dest)
        cards.move(fromOffsets: source, toOffset: dest)
        isChange = true
    }
    private func saveMoving() {
        if isChange {
            reSorting()
               GroupDataManager.shared.updateCards(to: cards) { _ in
                    self.isChange = false
            }
        }
    }
    //MARK: -  сортировка карточек
    private func reSorting() {
        for index in cards.indices {
                cards[index].sort = index + 1
                cards[index].date = Date().timeStamp()
                cards[index].idUser = idUser
        }
    }
}
