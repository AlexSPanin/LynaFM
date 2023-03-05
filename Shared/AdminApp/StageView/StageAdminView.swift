//
//  StageAdminView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 11.02.2023.
//

import SwiftUI

struct StageAdminView: View {
    @ObservedObject var viewModelAdmin: AdminAppViewModel
    @StateObject var viewModel = StageAdminViewModel()
    @State private var isEditing: Bool = false
    var body: some View {
        ZStack {
            TopLabelView(label: viewModel.label)
            VStack {
                if viewModel.showTab {
                    StageTabView(viewModel: viewModel)
                }
                VStack {
                    HorizontalDividerLabelView(label: TypeMessage.or.label)
                    TextButton(text: TypeMessage.back.label ,
                               size: screen * 0.35,
                               color: mainRigth) {
                        viewModelAdmin.showView = .start
                    }
                }
                .padding(.top, hPadding)
                Spacer()
            }
            .padding(.top, 60)
        }
        .sheet(isPresented: $viewModel.showAdd) {
            CreatedStageView(viewModel: viewModel, isEditing: isEditing)
        }
    }
}

