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
            return .footnote
        case WIDTH * 0.3..<WIDTH * 0.5:
            return .callout
        default:
            return .body
        }
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: buttonCorner)
                .foregroundColor(.accentColor).opacity(0.8)
                .frame(width: width, height: height)
                .overlay(
                    Text(text)
                        .font(font)
                        .foregroundColor(.black)
                )
        }
    }
}

struct TextButton: View {
    let text: String
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .font(.footnote)
                .underline()
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .frame(width: WIDTH * 0.35, alignment: .center)
        }
    }
}
