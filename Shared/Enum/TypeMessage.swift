//
//  TypeMessage.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.03.2023.
//

import Foundation

enum TypeMessage {
    case errorDelete
    case errorCardUse
    case errorNameEmpty
    case errorNoteEmpty
    case warningConfirm
    
    case enter
    case edit
    case back
    case add
    case sort
    case save
    case addCard
    case addColor
    
    case name
    case note
    case description
    case lang
    case or
    case open
    case close
    case element
    
    case loadImage
    case enterEmail
    
    case admin
    case category
    case group
    case propriety
    case vendor
    case parts
    case colors
    case products
    
    case label_vendor
    case label_category
    case label_group
    case label_propriety
    
    case open_propriety
    case open_image
    case open_name
    case open_model
    case open_price
    case open_spec
    
    var label: String {
        switch self {
        case .errorDelete:
            return languageType == .rus ? "ОШИБКА УДАЛЕНИЯ!" : "DELETION ERROR!"
        case .errorCardUse:
            return languageType == .rus ? "ОШИБКА!\nКарточка используется в\n других документах!" : "ERROR!\n The card is used in \n other documents!"
        case .warningConfirm:
            return languageType == .rus ? "Предупреждение!\nПодтвердите действие!" : "Warning!\nconfirm the action!"
        case .errorNameEmpty:
            return languageType == .rus ? "ОШИБКА!\nЗаполните Наименование" : "ERROR!\nfill in the Name"
        case .edit:
            return languageType == .rus ? "Редактировать" : "Edit"
        case .addCard:
            return languageType == .rus ? "Добавить новую карточку." : "Add a new card."
        case .enter:
            return languageType == .rus ? "Продолжить" : "Enter"
        case .back:
            return languageType == .rus ? "Закрыть" : "Back"
        case .name:
            return languageType == .rus ? "Наименование" : "Name"
        case .lang:
            return languageType == .rus ? "Язык отображения: " : "Language: "
        case .loadImage:
            return languageType == .rus ? "Загрузить изображение." : "Load image."
        case .add:
            return languageType == .rus ? "Добавить" : "Add"
        case .sort:
            return languageType == .rus ? "Сортировка" : "Sort"
        case .save:
            return languageType == .rus ? "Сохранить" : "Save"
        case .or:
            return languageType == .rus ? "или" : "OR"
        case .category:
            return languageType == .rus ? "Справочник категорий" : "Directory of categories"
        case .group:
            return languageType == .rus ? "Справочник групп" : "Directory of groups"
        case .propriety:
            return languageType == .rus ? "Справочник свойств" : "Directory of property"
        case .admin:
            return languageType == .rus ? "Административный раздел" : "Administrative section"
        case .enterEmail:
            return languageType == .rus ? "Введите email" : "Enter Email"
        case .errorNoteEmpty:
            return languageType == .rus ? "Все поля должны\nбыть заполнены" : "All fields must\nbe filled in"
        case .vendor:
            return languageType == .rus ? "Справочник производителей" : "Directory of Manufacturers"
        case .note:
            return languageType == .rus ? "Примечание" : "Note"
        case .description:
            return languageType == .rus ? "Описание" : "Description"
        case .open:
            return languageType == .rus ? "Открыть настройки" : "Open settings"
        case .close:
            return languageType == .rus ? "Закрыть настройки" : "Close settings"
        case .parts:
            return languageType == .rus ? "Справочник частей модели" : "Model Parts Reference"
        case .element:
            return languageType == .rus ? "Справочник элементов" : "Directory of Elements"
        case .colors:
            return languageType == .rus ? "Справочник цветовых коллекций" : "Directory of Colors"
        case .products:
            return languageType == .rus ? "Карточки продуктов" : "Directory of Products"
        case .addColor:
            return languageType == .rus ? "Выбрать цвет вручную:" : "Add new Color"
        case .label_vendor:
            return languageType == .rus ? "Производитель" : "Vendor"
        case .label_category:
            return languageType == .rus ? "Категория товара" : "Product Category"
        case .label_group:
           return languageType == .rus ? "Товарные группы" : "Product Group"
        case .label_propriety:
            return languageType == .rus ? "Свойства товара" : "Product Propriety"
        case .open_propriety:
            return languageType == .rus ? "Настройки свойств" : "Property Settings"
        case .open_image:
            return languageType == .rus ? "Настройки изображений" : "Image Settings"
        case .open_name:
            return languageType == .rus ? "Настройки наименований" : "Name Settings"
        case .open_model:
            return languageType == .rus ? "Настройка модели" : "Model Setup"
        case .open_price:
            return languageType == .rus ? "Настройка стоимости" : "Price Setting"
        case .open_spec:
            return languageType == .rus ? "Настройка спецификации" : "Specification Setting"
        }
    }
}

