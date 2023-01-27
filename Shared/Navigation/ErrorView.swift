//
//  ErrorView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 25.01.2023.
//

import SwiftUI

struct ErrorView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(nameLogo)
                .resizable()
                .interpolation(.medium)
                .aspectRatio(contentMode: .fit)
                .frame(width: WIDTH * 0.3)
            Text("Ошибка загрузки Базы Данных")
                .font(.callout)
                .lineLimit(1)
                .minimumScaleFactor(scaleFactor)
                .padding(.horizontal)
            Spacer()
        }
        .ignoresSafeArea()
    }
}

