//
//  CustomButton.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct CustomButton: View {
    
    let text: String
    let width: CGFloat
    let action: () -> Void
    var height: CGFloat {
        return width * 0.2
    }
    var font: Font {
        switch width {
        case 0..<WIDTH * 0.3:
            return fontSm
        case WIDTH * 0.3..<WIDTH * 0.5:
            return fontS
        default:
            return .body
        }
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: corner)
                .foregroundColor(mainDark)
                .frame(width: width, height: height)
                .overlay(
                    Text(text)
                        .font(font)
                        .foregroundColor(.black)
                )
        }
    }
}
