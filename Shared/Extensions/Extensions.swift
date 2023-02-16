//
//  extensions.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation
import SwiftUI
import UIKit

extension Bundle {
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Could not determine the application name"
    }
    var appBuild: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Could not determine the application build number"
    }
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Could not determine the application version"
    }
    func decode<T: Decodable>(_ type: T.Type,
                              from file: String,
                              dateDecodingStategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
                              keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Error: Failed to locate \(file) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Error: Failed to load \(file) from bundle.")
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Error: Failed to decode \(file) from bundle.")
        }
        return loaded
    }
}

extension UIDevice {
    struct DeviceModel: Decodable {
        let identifier: String
        let model: String
        static var all: [DeviceModel] {
            Bundle.main.decode([DeviceModel].self, from: "DeviceModels.json")
        }
    }
    var modelName: String {
        #if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        #endif
        return DeviceModel.all.first {$0.identifier == identifier }?.model ?? identifier
    }
}

// MARK: - Одиночная вибрация
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

// удаление из строки справа от указанного до указанного (включая его)
extension String {
    // обрезает справа строку от первого встретившевося символа (включая символ)
    func getInterval(to start: Int, count: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: start)
        let finish = self.index(start, offsetBy: count)
        let range = start..<finish
        return String(self[range])
    }
    // обрезает справа строку от первого встретившевося символа (включая символ)
    func croppingFirstRigthSimbols(_ element: Character) -> String {
        if let index = self.firstIndex(of: element) {
            return String(self[..<index])
        }
        return self
    }
    // обрезает слева строку от первого встретившевося символа (включая символ)
    func croppingFirstLeftSimbols(_ element: Character) -> String {
        if let index = self.firstIndex(of: element) {
            let i = self.index(after: index)
            return String(self[i...])
        }
        return self
    }
    // обрезает справа строку от последнего встретившевося символа (включая символ)
    func croppingLastRigthSimbols(_ element: Character) -> String {
        if let index = self.lastIndex(of: element) {
            return String(self[..<index])
        }
        return self
    }
    // обрезает слева строку от последнего встретившевося символа (включая символ)
    func croppingLastLeftSimbols(_ element: Character) -> String {
        if let index = self.lastIndex(of: element) {
            let i = self.index(after: index)
            return String(self[i...])
        }
        return self
    }
    // проверяем наличие символа
    func checkSimbol(_ element: Character) -> Bool {
       return self.contains(where: {$0 == element})
    }
}


extension UIColor {
    convenience init(_ hex: String) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") { cString.removeFirst() }
        if cString.count != 8 {
            self.init("00000000")
            return }
        var rgbaValue:UInt64 = 0
            Scanner(string: cString).scanHexInt64(&rgbaValue)
        
        self.init(
            red: CGFloat((rgbaValue & 0xFF000000) >> 24) / 255.0,
            green: CGFloat((rgbaValue & 0x00FF0000) >> 16) / 255.0,
            blue: CGFloat((rgbaValue & 0x0000FF00) >> 8) / 255.0,
            alpha: CGFloat((rgbaValue & 0x000000FF)) / 255.0
        )
    }
    
    func hexDescription() -> String {
        let red = String(Int(self.ciColor.red * 255), radix: 16)
        let blue = String(Int(self.ciColor.blue * 255), radix: 16)
        let green = String(Int(self.ciColor.green * 255), radix: 16)
        let alpha = String(Int(self.ciColor.alpha * 255), radix: 16)
        return String("#\(red + blue + green + alpha)")
    }
    
}

extension Color {
    static let greenAR = Color(#colorLiteral(red: 0.2196078431, green: 0.6901960784, blue: 0, alpha: 1))
    static let darkGreenAR = Color(#colorLiteral(red: 0.1911668777, green: 0.3707632422, blue: 0.2023646832, alpha: 1))
    static let blackAR = Color(#colorLiteral(red: 0.1285863519, green: 0.1285863519, blue: 0.1285863519, alpha: 1)).opacity(0.8)
    static let grayAR = Color(#colorLiteral(red: 0.6658725142, green: 0.6658725142, blue: 0.6658724546, alpha: 1))
    static let ligthGrayAR = Color(#colorLiteral(red: 0.7530785203, green: 0.7530786395, blue: 0.7530786395, alpha: 1))
    static let brownAR = Color(#colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)).opacity(0.1)
    static let ligthBrownAR = Color(#colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)).opacity(0.05)
    static let darkBrownAR = Color(#colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1)).opacity(0.4)
    static let cyanAR = Color(#colorLiteral(red: 0, green: 0.7377668619, blue: 0.8324059844, alpha: 1))
    static let ligthCyanAR = Color(#colorLiteral(red: 0.8169445992, green: 0.9721707702, blue: 0.9813576341, alpha: 1))
    static let redAR = Color(#colorLiteral(red: 0.9989674687, green: 0.5950558186, blue: 0.595369339, alpha: 1))
    static let whiteAR = Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    
    func hex(hex: String) -> Color {
        let uiColor = UIColor.init(hex)
        return Color(uiColor: uiColor)
    }
    
    func hexDescription() -> String {
        return self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    }

}
