//
//  VersionValidateView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct VersionValidateView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            Text("Закройте приложение.\nСкачайте и установите\nновую версию!")
                .multilineTextAlignment(.center)
                .font(.callout)
            Image(nameLogo)
                .resizable()
                .interpolation(.medium)
                .aspectRatio(contentMode: .fit)
                .frame(width: WIDTH * 0.3)
        }
    }
}
