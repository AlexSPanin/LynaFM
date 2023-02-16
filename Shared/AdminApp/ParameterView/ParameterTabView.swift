//
//  ParameterTabView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 13.02.2023.
//

import SwiftUI

struct ParameterTabView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: ParameterAdminViewModel
    var body: some View {
        VStack {
            ButtonMoveAdd(isMove: $viewModel.isMove, showAdd: $viewModel.showAdd)
        }
    }
}
