//
//  StageAdminViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 11.02.2023.
//

import Foundation

class StageAdminViewModel: ObservableObject {
    @Published var label = "Справочник производственных этапов"
    @Published var cards: [ProductionStage] = []
    @Published var card = ProductionStage()
    @Published var nameUser = ""
    @Published var date = ""

    @Published var showTab = false
    
    //MARK: - создание карточки
    @Published var isAdd = false {
        didSet {
            add()
        }
    }
    @Published var showAdd = false {
        didSet {
            if showAdd {
                label = "Создать новую карточку"
                card = ProductionStage()
                date = Date().timeStamp().croppingLastRigthSimbols(" ")
                isActive = true
            } else {
                closeViews()
            }
        }
    }
    //MARK: -  редактирование карточки
    @Published var isMove = false {
        didSet {
            saveMoving()
        }
    }
    
    //MARK: -  было изменение карточки или коллекции
    @Published var isChange = false {
        didSet {
            print("isChange \(isChange)")
        }
    }
    
    //MARK: -  редактирование карточки
    @Published var showEdit = false {
        didSet {
            if showEdit {
                label = "Редактировать карточку"
                date = Date().timeStamp().croppingLastRigthSimbols(" ")
                isActive = card.isActive
            } else {
                closeViews()
            }
        }
    }
    @Published var isEdit = false {
        didSet {
            edit()
        }
    }
    
    //MARK: -  деактивация карточки
    @Published var isActive = false {
        didSet {
            if isActive != card.isActive {
                checkActive()
            }
        }
    }

    //MARK: -  отработка экрана ошибки
    @Published var errorText = ""
    @Published var errorOccured = false
    @Published var typeNote = false
    
    var idUser = ""

    init() {
        print("START: StageAdminViewModel")
        StorageManager.shared.load(type: .user, model: UserAPP.self) { card in
            if let card = card {
                self.idUser = card.id
                self.nameUser = card.name + " " + card.surname
            }
        }
        fethNetwork()
        
    }
    deinit {
        print("CLOSE: StageAdminViewModel")
    }
    
    private func closeViews() {
        label = "Справочник производственных этапов"
    }
    
    //MARK: -  получение актуального массива  из сети
    private func fethNetwork() {
        print("Получение коллекции карточек из сети")
        StageDataManager.shared.loadCollection { stages in
            if let stages = stages {
                self.cards = stages.sorted(by: {$0.sort < $1.sort})
                self.saveStorage()
                self.showTab.toggle()
            }
        }
    }

    //MARK: - редактируем карточку производственного участка
    private func edit() {
        print("Редактирование карточки")
        if isChange {
            if let index = cards.firstIndex(where: {$0.id == card.id}) {
                card.date = Date().timeStamp()
                card.idUser = idUser
                cards[index] = card
                cards = cards.sorted(by: {$0.sort < $1.sort})
                StageDataManager.shared.updateCard(to: card) { _ in
                    self.saveStorage()
                    self.isChange = false
                    self.showEdit.toggle()
                }
            }
        } else {
            self.showEdit.toggle()
        }
    }
    
    private func add() {
        print("Создание карточки")
        card.sort = cards.count + 1
        card.date = date
        card.idUser = idUser
        cards.append(card)
        StageDataManager.shared.createCard(to: card) { _ in
            self.saveStorage()
            self.showAdd.toggle()
        }
    }
    
    private func checkActive() {
        print("проверка на Деактивация карточки")
        if !isActive {
            if card.countUse != 0 {
                errorText = "ОШИБКА!\nКарточка используется в\n других документах!"
                errorOccured = true
                typeNote = false
            } else {
                errorText = "Предупреждение!\nПодтвердите деактивацию картоки!"
                errorOccured = true
                typeNote = true
            }
        } else {
            inActive()
        }
    }
    
    func inActive() {
        card.isActive.toggle()
        isChange = true
    }
    
    func move(from source: IndexSet, to dest: Int) {
        cards.move(fromOffsets: source, toOffset: dest)
        isChange = true
    }
    
    private func saveMoving() {
        if isChange {
            reSorting()
            StageDataManager.shared.updateCards(to: cards) { status in
                self.saveStorage()
                self.isChange = false
                self.closeViews()
            }
        }
    }
    
    private func saveStorage() {
        let cards = cards as Any
        StorageManager.shared.save(type: .stages, model: [ProductionStage].self, collection: cards)
    }
    
    private func reSorting() {
        for index in 0 ..< cards.count {
            cards[index].sort = index + 1
            cards[index].date = Date().timeStamp()
            cards[index].idUser = idUser
        }
    }
}
