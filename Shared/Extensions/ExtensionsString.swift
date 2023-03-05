//
//  ExtensionsString.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.03.2023.
//

import Foundation
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
