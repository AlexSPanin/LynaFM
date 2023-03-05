//
//  GroupAdminView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.02.2023.
//

import SwiftUI

struct GroupAdminView: View {
    @ObservedObject var viewModelAdmin: AdminAppViewModel
    @StateObject var viewModel = GroupAdminViewModel()
    @State private var isEditing: Bool = false
    var body: some View {
        ZStack {
            TopLabelView(label: viewModel.label)
            VStack {
                if viewModel.showTabCollection {
                    GroupTabView(viewModel: viewModel)
                }
            }
            .padding(.top, 60)
            VStack {
                Spacer()
                HorizontalDividerLabelView(label: TypeMessage.or.label)
                TextButton(text: TypeMessage.back.label ,
                           size: screen * 0.35,
                           color: mainRigth) {
                    viewModelAdmin.showView = .start
                }
            }
            .padding(.vertical, hPadding)
        }
        .sheet(isPresented: $viewModel.showAdd) {
            CreatedGroupView(viewModel: viewModel, isEditing: isEditing)
        }
    }
}
