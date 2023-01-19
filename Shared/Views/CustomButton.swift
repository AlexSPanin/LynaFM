//
//  CustomButton.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct CustomButton: View {
    
    let text: String
    let action: () -> Void
    let size = CGSize(width: WIDTH * 0.3, height: WIDTH * 0.07)

    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: buttonCorner)
                .foregroundColor(.accentColor).opacity(0.8)
                .frame(width: size.width, height: size.height)
                .overlay(
                    Text(text)
                        .font(.footnote)
                        .foregroundColor(.black)
                )
        }
    }
}

struct TextButton: View {
    
    let text: String
    let action: () -> Void
    let size = CGSize(width: WIDTH * 0.4, height: WIDTH * 0.07)
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .font(.footnote)
                .underline()
                .minimumScaleFactor(0.9)
                .frame(width: size.width, height: size.height, alignment: .center)
                
        }
    }
}
