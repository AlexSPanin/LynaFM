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

//MARK: - #FFFFFFFF отработка установки и получения цвета
extension UIColor {
    public convenience init (hex: String) {
        let r, g, b, a: CGFloat
        
   //     let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = hex.lowercased()
        
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255
                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }
        self.init(red: 0, green: 0, blue: 0, alpha: 0)
        return
    }
    
    func hexDescription() -> String {
        let red = String(Int(self.ciColor.red * 255), radix: 16)
        let blue = String(Int(self.ciColor.blue * 255), radix: 16)
        let green = String(Int(self.ciColor.green * 255), radix: 16)
        let alpha = String(Int(self.ciColor.alpha * 255), radix: 16)
        return String("\(red + blue + green + alpha)")
    }
    
}
//MARK: - #FFFFFFFF отработка установки и получения цвета
extension Color {
    func hex(hex: String) -> Color {
        let uiColor = UIColor.init(hex: hex) 
        return Color(uiColor: uiColor)
    }
    
    func hexDescription() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        let ui = UIColor(self)
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(
            format: "%02X%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff),
            Int(a * 0xff)
        )
    }

}

