//
//  ReturnAndSaveButton.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 05.03.2023.
//

import SwiftUI

struct ReturnAndSaveButton: View {
    let disableSave: Bool
    let disableBack: Bool
    let actionSave: () -> Void
    let actionBack: () -> Void
    var body: some View {
        VStack {
            Spacer()
            VStack {
                CustomButton(text: TypeMessage.save.label, width: WIDTH * 0.4) {
                    actionSave()
                }
                .disabled(disableSave)
                .opacity(disableSave ? 0 : 1)
                .padding(.top, 5)
                
                HorizontalDividerLabelView(label: TypeMessage.or.label)
                
                TextButton(text: TypeMessage.back.label, size: WIDTH * 0.35, color: mainRigth) {
                    actionBack()
                }
                .disabled(disableBack)
                .opacity(disableBack ? 0 : 1)
                .padding(.bottom, 2 * hPadding)
            }
            .background( Color.white )
        }
        .ignoresSafeArea()
    }
}

