//
//  ExtensionsColor.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.03.2023.
//

import SwiftUI
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

// Codable UIColor
@propertyWrapper
struct CodableColor {
    var wrappedValue: UIColor
}

extension CodableColor: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        guard let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid color"
            )
        }
        wrappedValue = color
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try NSKeyedArchiver.archivedData(withRootObject: wrappedValue, requiringSecureCoding: true)
        try container.encode(data)
    }
}

