//
//  ParameterAdminView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 13.02.2023.
//

import SwiftUI

struct ParameterAdminView: View {
    @ObservedObject var viewModelAdmin: AdminAppViewModel
    @StateObject var viewModel = ParameterAdminViewModel()
    @State private var isEditing: Bool = false
    var body: some View {
        ZStack {
            TopLabelView(label: viewModel.label)
            VStack {
                if viewModel.showTabCollection {
                    ParameterTabView(viewModel: viewModel)
                }
            }
            .padding(.top, 60)
            VStack {
                Spacer()
                HorizontalDividerLabelView(label: TypeMessage.or.label)
                HStack(alignment: .center, spacing: 20) {
                    TextButton(text: TypeMessage.back.label ,
                               size: screen * 0.35,
                               color: mainRigth) {
                        viewModelAdmin.showView = .start
                    }
                }
            }
            .padding(.vertical, hPadding)
        }
        .sheet(isPresented: $viewModel.showAdd) {
            CreatedParameterView(viewModel: viewModel, isEditing: isEditing)
        }
    }
}
