//
//  TopLabelView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import SwiftUI

struct TopLabelView: View {
    let label: String
    var body: some View {
        VStack() {
            Text(label)
                .font(.body)
                .foregroundColor(.accentColor)
                .minimumScaleFactor(0.9)
                .lineLimit(1)
                .frame(width: WIDTH * 0.9, alignment: .leading)
            Divider()
                .frame(width: WIDTH * 0.9, height: 1, alignment: .leading)
            Spacer()
        }
        .padding(.top, hPadding)
    }
}

struct TopLabelButtonView: View {
    let label: String
    let action: () -> Void
    
    var body: some View {
        VStack() {
            HStack {
                Text(label)
                    .font(.body)
                    .foregroundColor(.accentColor)
                    .minimumScaleFactor(0.9)
                    .lineLimit(1)
                    .frame(width: WIDTH * 0.8, alignment: .leading)
                Button(action: {
                    action()
                }, label: {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .interpolation(.medium)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: WIDTH * 0.05, alignment: .center)
                        .foregroundColor(.accentColor)
                })
            }
            
            Divider()
                .frame(width: WIDTH * 0.9, height: 1, alignment: .leading)
            Spacer()
        }
        .padding(.top, hPadding)
    }
}
