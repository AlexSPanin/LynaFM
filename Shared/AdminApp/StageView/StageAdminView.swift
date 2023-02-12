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
                    HorizontalDividerLabelView(label: "или")
                    HStack(alignment: .center, spacing: 20) {
                        TextButton(text: "Вернуться") {
                            viewModelAdmin.showView = .start
                        }
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
        // отработка сообщений об ошибках
//        if viewModel.errorOccured {
//            NotificationView(text: viewModel.errorText, button: "Подтвердить", button2: "Отменить") {
//                viewModel.errorOccured.toggle()
//                viewModel.isDeleteConfirm.toggle()
//            } action2: {
//                viewModel.errorOccured.toggle()
//                viewModel.isDelete.toggle()
//            }
//        }
    }
}

