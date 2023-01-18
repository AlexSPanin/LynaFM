//
//  extensions.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.01.2023.
//

import Foundation
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
    func rusDateShort() -> String {
        let date = self.formatted(Date.FormatStyle()
            .day(.twoDigits)
            .month(.twoDigits)
            .year(.twoDigits)
            .locale(Locale(identifier: "ru_RU"))
        )
        return String(date)
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
