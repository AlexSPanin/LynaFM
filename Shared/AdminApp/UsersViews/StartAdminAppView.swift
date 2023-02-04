//
//  StartAdminAppView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import SwiftUI

struct StartAdminAppView: View {
    @EnvironmentObject var navigation: NavigationViewModel
    @ObservedObject var viewModel: AdminAppViewModel
    var body: some View {
        ZStack {
            TopLabelView(label: viewModel.label)
            VStack(alignment: .center, spacing: 20) {
                CustomButton(text: "Карточки Товара", width: WIDTH * 0.7) {
                    viewModel.showView = .product
                }
                CustomButton(text: "Карточки Материалов", width: WIDTH * 0.7) {
                    viewModel.showView = .material
                }
                CustomButton(text: "Тех. карты", width: WIDTH * 0.7) {
                    viewModel.showView = .card
                }
                
                
                HorizontalDividerLabelView(label: "или")
                HStack(alignment: .center, spacing: 20) {
                    TextButton(text: "Сменить профиль") {
                        viewModel.isExit.toggle()
                    }
                    TextButton(text: "Общие справочники") {
                        viewModel.showView = .property
                    }
                }
            }
        }
        .onChange(of: viewModel.isExit) { newValue in
            if newValue {
                navigation.view = .auth
            }
        }
    }
}
