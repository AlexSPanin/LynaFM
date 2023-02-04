//
//  SwiftUIView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//

import SwiftUI

struct LoadView: View {
    let label: String
    var body: some View {
        VStack {
            Spacer()
            Image(nameLogo)
                .resizable()
                .interpolation(.medium)
                .aspectRatio(contentMode: .fit)
                .frame(width: WIDTH * 0.3)
            ProgressView(label)
                .foregroundColor(.accentColor)
                .font(.callout)
                .lineLimit(1)
                .minimumScaleFactor(scaleFactor)
                .padding(.horizontal)
            Spacer()
        }
        .ignoresSafeArea()
    }
}

