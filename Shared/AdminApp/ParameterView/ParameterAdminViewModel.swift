//
//  ParameterAdminViewModel.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 13.02.2023.
//

import Foundation

class ParameterAdminViewModel: ObservableObject {
    @Published var label = "Справочник параметров материалов и продуктов"
    @Published var cards = [ParameterAPP]()
    @Published var name: String = ""
    @Published var description: String = ""
    
    
    @Published var card: Int?
    @Published var element: Int?

    @Published var nameUser = ""
    @Published var date = ""
    @Published var sort = ""
    
    
    @Published var showTab = false
    
    //MARK: - создание карточки коллекции
    @Published var isAdd = false {
        didSet {
            add(to: card)
        }
    }
    @Published var showAdd = false

    //MARK: -  редактирование карточки
    @Published var isEdit = false {
        didSet {
            if let card = card {
                edit(to: card, element: element)
            }
        }
    }
    @Published var showEdit = false
    
    
    //MARK: -  деактивация карточки
    @Published var isActive = false {
        didSet {
            if let card = card, isActive != cards[card].parameter.isActive {
                checkActive(to: card, element: element)
            }
        }
    }
    //MARK: -  редактирование карточки
    @Published var isMove = false {
        didSet {
            saveMoving(to: card)
        }
    }
    
    //MARK: -  было изменение карточки или коллекции
    @Published var isChange = false {
        didSet {
            print("isChange \(isChange)")
        }
    }
    
    //MARK: -  отработка экрана ошибки
    @Published var errorText = ""
    @Published var errorOccured = false
    @Published var typeNote = false
    
    var idUser = ""
    
    init() {
        print("START: ParameterAdminViewModel")
        idUser = AuthUserManager.shared.currentUserID()
        UserDataManager.shared.getNameUser(to: idUser) { name in
            if let name = name {
                self.nameUser = name
                print("\(name)")
            }
        }
        fethNetwork()
    }
    deinit {
        print("CLOSE: ParameterAdminViewModel")
    }
    
    private func add(to card: Int?) {
        print("Создание карточки")
        if let card = card {
            var element = ParameterElement()
            element.id = UUID().uuidString
            element.idCollection = cards[card].parameter.id
            element.idUser = idUser
            element.date = date
            element.sort = cards[card].elements.count + 1
            element.name = name
            element.label = description
            cards[card].elements.append(element)
            ParameterDataManager.shared.createSubCard(to: cards[card].parameter.id, card: element) { _ in
                self.saveStorage()
                self.showAdd.toggle()
            }
        } else {
            var parameter = Parameter()
            parameter.id = UUID().uuidString
            parameter.idUser = idUser
            parameter.date = date
            parameter.sort = cards.count + 1
            parameter.name = name
            parameter.label = description
            ParameterDataManager.shared.createCard(to: parameter) { _ in
                self.cards.append(ParameterAPP(parameter: parameter))
                self.saveStorage()
                self.showAdd.toggle()
            }
        }
    }
    
    private func edit(to card: Int, element: Int?) {
        print("Редактирование карточки")
        if isChange {
            if let element = element {
                cards[card].elements[element].date = date
                cards[card].elements[element].idUser = idUser
                cards[card].elements[element].name = name
                cards[card].elements[element].label = description
                let elements = cards[card].elements[element]
                ParameterDataManager.shared.updateSubCard(to: cards[card].parameter.id,
                                                          element: elements) { _ in
                    self.saveStorage()
                    self.isChange = false
                    self.showEdit.toggle()
                }
            } else {
                cards[card].parameter.date = date
                cards[card].parameter.idUser = idUser
                cards[card].parameter.name = name
                cards[card].parameter.label = description
                let parameter = cards[card].parameter
                ParameterDataManager.shared.updateCard(to: parameter) { _ in
                    self.saveStorage()
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
        ParameterDataManager.shared.loadCollection { parameters in
            if let parameters = parameters {
                parameters.forEach { parameter in
                    var parameterAPP = ParameterAPP(parameter: parameter)
                    ParameterDataManager.shared.loadSubCollection(to: parameter.id) { elements in
                        if let elements = elements {
                            let elements = elements.sorted(by: {$0.sort < $1.sort})
                            parameterAPP.elements = elements
                        }
                    }
                    self.cards.append(parameterAPP)
                }
                self.cards = self.cards.sorted(by: {$0.parameter.sort < $1.parameter.sort})
                self.saveStorage()
                self.showTab.toggle()
            }
        }
    }
    
    private func closeViews() {
        label = "Справочник параметров материалов и продуктов"
        fethStorage()
    }
    
    
    func move(to card: Int?, from source: IndexSet, to dest: Int) {
        if let card = card {
            cards[card].elements.move(fromOffsets: source, toOffset: dest)
        } else {
            cards.move(fromOffsets: source, toOffset: dest)
        }
        isChange = true
    }
    
    private func saveMoving(to card: Int?) {
        if isChange {
            reSorting(to: card)
            if let card = card {
                ParameterDataManager.shared.updateSubCards(to: cards[card].parameter.id , cards: cards[card].elements) { _ in
                    self.saveStorage()
                    self.isChange = false
                    self.closeViews()
                }
            } else {
                let collection: [Parameter] = cards.compactMap({ $0.parameter})
                ParameterDataManager.shared.updateCards(to: collection) { _ in
                    self.saveStorage()
                    self.isChange = false
                    self.closeViews()
                }
            }
            
        }
    }
    //MARK: -  методы по работе с сохранением в памяти
    private func fethStorage() {
        print("Получение коллекции карточек  из памяти")
        StorageManager.shared.load(type: .parameters, model: [ParameterAPP].self) { cards in
            if let cards = cards {
                self.cards = cards.sorted(by: {$0.parameter.sort < $1.parameter.sort})
            }
        }
    }
    private func saveStorage() {
        let cards = cards as Any
        StorageManager.shared.save(type: .parameters, model: [ParameterAPP].self, collection: cards)
    }
    
    //MARK: - методы переключения и проверки активного статуса карточки
    private func checkActive(to card: Int, element: Int?) {
        print("проверка на Деактивация карточки")
        var countUse = cards[card].parameter.countUse
        if let element = element {
            countUse = cards[card].elements[element].countUse
        }
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
            inActive(to: card, element: element)
        }
    }
    
    func inActive(to card: Int, element: Int?) {
        if let element = element {
            cards[card].elements[element].isActive.toggle()
        } else {
            cards[card].parameter.isActive.toggle()
        }
        isChange = true
    }
    
    
    private func reSorting(to card: Int?) {
        if let card = card {
            for index in 0..<cards[card].elements.count {
                cards[card].elements[index].sort = index + 1
                cards[card].elements[index].date = Date().timeStamp()
                cards[card].elements[index].idUser = idUser
            }
        } else {
            for index in 0 ..< cards.count {
                cards[index].parameter.sort = index + 1
                cards[index].parameter.date = Date().timeStamp()
                cards[index].parameter.idUser = idUser
            }
        }
    }
    
}
