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
                HorizontalDividerLabelView(label: "или")
                HStack(alignment: .center, spacing: 20) {
                    TextButton(text: "Вернуться") {
                        viewModelAdmin.showView = .start
                    }
                    .foregroundColor(.cyan.opacity(0.8))
                }
            }
            .padding(.vertical, hPadding)
        }
        .sheet(isPresented: $viewModel.showAdd) {
            CreatedGroupView(viewModel: viewModel, isEditing: isEditing)
        }
    }
}
