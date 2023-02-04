//
//  UserLineView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import SwiftUI

struct UserLineView: View {
    let user: User
    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: hPadding) {
                Image(systemName: "circle.fill")
                    .resizable()
                    .interpolation(.medium)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: WIDTH * 0.03, alignment: .center)
                    .foregroundColor(user.isActive ? .green : .red)
                if user.isActive {
                Text("\(user.name) \(user.surname)")
                    .minimumScaleFactor(0.9)
                    .lineLimit(1)
                } else {
                    Text("\(user.name) \(user.surname)")
                        .strikethrough(color: .accentColor)
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)
                }
                    
                Spacer()
            }
            .font(.callout)
            Divider()
                .frame(width: WIDTH * 0.95, height: 1, alignment: .leading)
        }
        .padding(.horizontal, hPadding)
        .frame(width: WIDTH * 0.95, height: WIDTH * 0.09, alignment: .leading)
    }
}
