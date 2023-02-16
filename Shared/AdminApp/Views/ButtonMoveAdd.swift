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
                    Text("OK")
                        .font(.body)
                        .foregroundColor(.cyan.opacity(0.8))
                    
                } else {
                Image(systemName: "arrow.up.arrow.down.circle")
                    .resizable()
                    .interpolation(.medium)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.cyan.opacity(0.8))
                    .frame(width: WIDTH * 0.05, alignment: .center)
                }
                
            }
            Spacer()
            Button {
                showAdd.toggle()
            } label: {
                Image(systemName: "plus.circle")
                    .resizable()
                    .interpolation(.medium)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.cyan.opacity(0.8))
                    .frame(width: WIDTH * 0.05, alignment: .center)
                
            }
            .disabled(isMove)
            .opacity(isMove ? 0 : 1)
            
        }

    }
}
