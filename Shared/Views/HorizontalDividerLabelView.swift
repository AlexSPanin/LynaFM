//
//  HorizontalDividerLabelView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct HorizontalDividerLabelView: View {
    let label: String
    let color: Color = .accentColor
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Divider()
                    .frame(width: WIDTH / 3, height: 1, alignment: .leading)
                    .background(color)
                Spacer()
                Text(label)
                    .font(.caption)
                Spacer()
                Divider()
                    .frame(width: WIDTH / 3, height: 1, alignment: .trailing)
                    .background(color)
                Spacer()
            }
        }
    }
}
