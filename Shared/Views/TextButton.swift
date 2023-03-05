//
//  TextButton.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.03.2023.
//

import SwiftUI

struct TextButton: View {
    let text: String
    let size: CGFloat
    let color: Color
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .font(fontSm)
                .underline()
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .frame(width: size, alignment: .center)
                .foregroundColor(color)
        }
    }
}
