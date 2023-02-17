//
//  ButtonsEditModeView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 13.02.2023.
//

import SwiftUI

struct ButtonMoveAdd: View {
    @Environment(\.editMode) private var editMode
    @Binding var isMove: Bool
    @Binding var showAdd: Bool
    var body: some View {
        HStack {
            Button {
                isMove.toggle()
                if isMove {
                    self.editMode?.wrappedValue = .active
                } else {
                    self.editMode?.wrappedValue = .inactive
                }
            } label: {
                if isMove {
                    Text("Сохранить")
                        .font(.body)
                        .foregroundColor(.cyan.opacity(0.8))
                } else {
                    Text("Сортировка")
                        .font(.body)
                        .foregroundColor(.cyan.opacity(0.8))
                }
            }
            Spacer()
            Button {
                showAdd.toggle()
            } label: {
                Text("Добавить")
                    .font(.body)
                    .foregroundColor(.cyan.opacity(0.8))
            }
            .disabled(isMove)
            .opacity(isMove ? 0 : 1)
        }
    }
}
