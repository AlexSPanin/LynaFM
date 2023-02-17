//
//  TopCardView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 17.02.2023.
//

import SwiftUI

struct TopCardView: View {
    @Environment(\.editMode) private var editMode
    @Binding var isActive: Bool
    let date: String
    let user: String
    let isEditing: Bool
    var body: some View {
        VStack(spacing: hPadding) {
            VStack (spacing: 5) {
                Text("Дата: \(date)")
                    .frame(width: WIDTH * 0.9, alignment: .leading)
                    .font(.footnote)
                    .lineLimit(1)
                    .minimumScaleFactor(scaleFactor)
                Text("Ответственный: \(user)")
                    .frame(width: WIDTH * 0.9, alignment: .leading)
                    .font(.footnote)
                    .lineLimit(1)
                    .minimumScaleFactor(scaleFactor)
            }
            .foregroundColor(.accentColor)
            .padding(.top, hPadding)
            HStack {
                Toggle(isOn: $isActive) {               
                    Text(isActive ? "Активна" : "Архив")
                        .font(.callout)
                        .lineLimit(1)
                        .minimumScaleFactor(scaleFactor)
                        .foregroundColor(isActive ? .cyan.opacity(0.8) : .orange.opacity(0.8))
                    
                }
                Spacer()
            }
            .disabled(!isEditing || editMode?.wrappedValue == .active)
            .opacity(editMode?.wrappedValue == .active ? 0.3 : 1)
        }
    }
}
