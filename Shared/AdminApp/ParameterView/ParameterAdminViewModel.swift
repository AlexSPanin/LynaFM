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
    
    //MARK: - переменные для работе с карточками коллекций
    //MARK: - признаки запуска методов
    @Published var isAdd = false {
        didSet {
            add()
        }
    }
    @Published var isEdit = false {
        didSet {
            edit(to: card)
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
                label = "Добавить новый параметр."
                date = Date().timeStamp().croppingLastRigthSimbols(" ")
                isActive = true
                name = ""
                description = ""
            } else {
                label = "Справочник параметров материалов и продуктов"
            }
        }
    }
    @Published var showEdit = false {
        didSet {
            if showEdit {
                if let card = card {
                    date = Date().timeStamp().croppingLastRigthSimbols(" ")
                    isActive = cards[card].parameter.isActive
                    name = cards[card].parameter.name
                    description = cards[card].parameter.label
                    label = "Редактировать: \(name)"
                    isEmptyElements = cards[card].elements.isEmpty
                }
            } else {
                label = "Справочник параметров материалов и продуктов"
            }
        }
    }
    
    //MARK: - признаки проверок состояния
    @Published var isChange = false
    @Published var isActive = false {
        didSet {
            if let card = card {
                if isActive != cards[card].parameter.isActive {
                checkActive(to: card)
                }
            }
        }
    }
    
    //MARK: - переменные для работе с карточками элементов коллекций
    //MARK: - признаки запуска методов
    @Published var isAddElement = false {
        didSet {
            addElement(to: card)
        }
    }
    @Published var isEditElement = false {
        didSet {
            editElement(to: card, element: element)
        }
    }
    @Published var isMoveElement = false {
        didSet {
            if let card = card {
                saveMovingElement(to: card)
            }
        }
    }
    //MARK: - признаки показа окон
    @Published var showAddElement = false {
        didSet {
            if showAddElement {
                label = "Добавить элемент."
                date = Date().timeStamp().croppingLastRigthSimbols(" ")
                isActiveElement = true
                name = ""
                description = ""
            } else {
                if let card = card {
                    name = cards[card].parameter.name
                    description = cards[card].parameter.label
                    label = "Редактировать: \(name)"
                }
            }
        }
    }
    @Published var showEditElement = false {
        didSet {
            if showEditElement {
                if let card = card, let element = element {
                    date = Date().timeStamp().croppingLastRigthSimbols(" ")
                    isActiveElement = cards[card].elements[element].isActive
                    name = cards[card].elements[element].name
                    description = cards[card].elements[element].value
                    label = "Редактировать: \(name)"
                    
                }
            } else {
                if let card = card {
                    name = cards[card].parameter.name
                    description = cards[card].parameter.label
                    label = "Редактировать: \(name)"
                }
            }
        }
    }
    
    
    //MARK: - признаки проверок состояния
    @Published var isChangeElement = false
    @Published var isEmptyElements = true
    @Published var isActiveElement = false {
        didSet {
            if let card = card, let element = element {
              if isActiveElement != cards[card].elements[element].isActive {
                checkActiveElement (to: card, element: element)
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
        print("START: ParameterAdminViewModel")
        idUser = AuthUserManager.shared.currentUserID()
        UserDataManager.shared.getNameUser(to: idUser) { name in
            if let name = name {
                self.nameUser = name
            }
        }
        fethNetwork()
    }
    deinit {
        print("CLOSE: ParameterAdminViewModel")
    }
    //MARK: - создание карточки коллекции
    private func add() {
        print("Создание карточки коллекции")
        isEmptyElements = true
        var parameter = Parameter()
        parameter.id = UUID().uuidString
        parameter.idUser = idUser
        parameter.date = Date().timeStamp()
        parameter.sort = cards.count + 1
        parameter.name = name
        parameter.label = description
        ParameterDataManager.shared.createCard(to: parameter) { _ in
            self.cards.append(ParameterAPP(parameter: parameter))
            self.showAddElement.toggle()
        }
    }
    //MARK: - создание карточки элемента коллекции
    private func addElement(to card: Int?) {
        print("Создание карточки элемента коллекции")
        if let card = card {
            var element = ParameterElement()
            element.id = UUID().uuidString
            element.idCollection = cards[card].parameter.id
            element.idUser = idUser
            element.date = Date().timeStamp()
            element.sort = cards[card].elements.count + 1
            element.name = name
            element.value = description
            cards[card].elements.append(element)
            ParameterDataManager.shared.createSubCard(to: cards[card].parameter.id, card: element) { _ in
                self.isEmptyElements = false
                self.showAddElement.toggle()
            }
        }
    }
    //MARK: - редактирование карточки коллекции
    private func edit(to card: Int?) {
        print("Редактирование карточки коллекции")
        if isChange {
            if let card = card {
                cards[card].parameter.date = Date().timeStamp()
                cards[card].parameter.idUser = idUser
                cards[card].parameter.name = name
                cards[card].parameter.label = description
                let parameter = cards[card].parameter
                ParameterDataManager.shared.updateCard(to: parameter) { _ in
                    self.isChange = false
                    self.showEdit.toggle()
                }
            }
        } else {
            showEdit.toggle()
        }
    }
    //MARK: - редактирование карточки элемента коллекции
    private func editElement(to card: Int?, element: Int?) {
        print("Редактирование карточки элемента коллекции")
        if isChange {
            if let card = card, let element = element {
                cards[card].elements[element].date = Date().timeStamp()
                cards[card].elements[element].idUser = idUser
                cards[card].elements[element].name = name
                cards[card].elements[element].value = description
                let elements = cards[card].elements[element]
                ParameterDataManager.shared.updateSubCard(to: cards[card].parameter.id,
                                                          element: elements) { _ in
                    self.isChange = false
                    self.showEditElement.toggle()
                }
            }
        } else {
            showEditElement.toggle()
        }
    }
    //MARK: -  получение актуального массива  из сети
    private func fethNetwork() {
        print("Получение коллекции карточек из сети")
        let myGroup = DispatchGroup()
        ParameterDataManager.shared.loadCollection { parameters in
            if let parameters = parameters {
                parameters.forEach { parameter in
                    var parameterAPP = ParameterAPP(parameter: parameter)
                    myGroup.enter()
                    ParameterDataManager.shared.loadSubCollection(to: parameter.id) { elements in
                        if let elements = elements {
                            let elements = elements.sorted(by: {$0.sort < $1.sort})
                            parameterAPP.elements = elements
                            myGroup.leave()
                        } else {
                            myGroup.leave()
                        }
                    }
                    myGroup.notify(queue: .main) {
                        self.cards.append(parameterAPP)
                    }
                }
                self.cards = self.cards.sorted(by: {$0.parameter.sort < $1.parameter.sort})
                self.showTabCollection.toggle()
            }
        }
    }

    //MARK: -  методы по сортировке коллекций
    func move(from source: IndexSet, to dest: Int) {
        cards.move(fromOffsets: source, toOffset: dest)
        isChange = true
    }
    private func saveMoving() {
        if isChange {
            reSorting(to: nil)
                let collection: [Parameter] = cards.compactMap({ $0.parameter})
                ParameterDataManager.shared.updateCards(to: collection) { _ in
                    self.isChange = false
            }
        }
    }
    //MARK: -  методы по сортировке элементов
    func moveElements(to card: Int?, from source: IndexSet, to dest: Int) {
        if let card = card {
            cards[card].elements.move(fromOffsets: source, toOffset: dest)
            isChangeElement = true
        }
    }
    private func saveMovingElement(to card: Int) {
        if isChangeElement {
            reSorting(to: card)
            ParameterDataManager.shared.updateSubCards(to: cards[card].parameter.id , cards: cards[card].elements) { _ in
                self.isChangeElement = false
            }
        }
    }
    
    //MARK: - методы переключения и проверки активного статуса карточки коллекции
    private func checkActive(to card: Int) {
        print("проверка на Деактивация карточки")
        let countUse = cards[card].parameter.countUse
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
            cards[card].parameter.isActive.toggle()
            isChange = true
        }
    }
    
    //MARK: - методы переключения и проверки активного статуса карточки элемента
    private func checkActiveElement(to card: Int, element: Int) {
        print("проверка на Деактивация карточки")
        let countUse = cards[card].elements[element].countUse
        if !isActiveElement {
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
            inActiveElement(to: card, element: element)
        }
    }
    
    func inActiveElement(to card: Int?, element: Int?) {
        if let card = card, let element = element {
            cards[card].elements[element].isActive.toggle()
            isChangeElement = true
        }
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
