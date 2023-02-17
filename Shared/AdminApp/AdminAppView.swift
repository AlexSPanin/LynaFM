//
//  RoleUserView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct AdminAppView: View {
    @StateObject var viewModel = AdminAppViewModel()
    var body: some View {
        ZStack {
            switch viewModel.showView {
            case .start:
                StartAdminAppView(viewModel: viewModel)
            case .user:
                UsersAdminAppView(viewModelAdmin: viewModel)
            case .stage:
                StageAdminView(viewModelAdmin: viewModel)
            case .parameter:
                ParameterAdminView(viewModelAdmin: viewModel)
            default:
                UsersAdminAppView(viewModelAdmin: viewModel)
                
            }
        }
    }
}

