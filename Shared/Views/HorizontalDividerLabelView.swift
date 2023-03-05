//
//  HorizontalDividerLabelView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct HorizontalDividerLabelView: View {
    let label: String
    let color: Color = mainColor
    var body: some View {
        ZStack {
            if label.isEmpty {
                Divider()
                    .frame(width: screen, height: 1, alignment: .leading)
                    .foregroundColor(color)
            } else {
                HStack {
                    Spacer()
                    Divider()
                        .frame(width: screen / 3, height: 1, alignment: .leading)
                        .foregroundColor(color)
                    Spacer()
                    Text(label)
                        .font(fontSx)
                    Spacer()
                    Divider()
                        .frame(width: screen / 3, height: 1, alignment: .trailing)
                        .foregroundColor(color)
                    Spacer()
                }
            }
        }
    }
}
