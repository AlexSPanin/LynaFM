//
//  extensions.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation
import SwiftUI
import UIKit

//MARK: - Одиночная вибрация
func NotificationFeedbackGenerator() {
    let tapticFeedback = UINotificationFeedbackGenerator()
    tapticFeedback.notificationOccurred(.success)
}

// приведение даты к российскому стандарту
extension Date {
    func timeStamp() -> String {
        let date = DateFormatter()
        date.dateFormat = "yyyy-MM-dd hh:mm:ss:ms"
        return date.string(from: self)
    }
}

// возвращает текст с разделенными тысячами и знаком рубля
extension Float {
    func getRusPrice() -> String {
            let numberForrmatter: NumberFormatter = NumberFormatter()
            numberForrmatter.groupingSeparator = " "
            numberForrmatter.groupingSize = 3
            numberForrmatter.usesGroupingSeparator = true
            numberForrmatter.decimalSeparator = "."
            numberForrmatter.numberStyle = NumberFormatter.Style.decimal
            guard let price = numberForrmatter.string(from: self as NSNumber) as String? else { return ""}
            return price + String(" ₽")
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


