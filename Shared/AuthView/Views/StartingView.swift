//
//  StartingView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct StartingView: View {
    @EnvironmentObject var navigation: NavigationViewModel
    @ObservedObject var viewModel: AuthViewModel
    private var name: String {
        viewModel.userAPP.name
    }
    private var surname: String {
        viewModel.userAPP.surname
    }
    private var image: UIImage? {
        UIImage(data: viewModel.userAPP.image)
    }
    private var roles: [UserRole: Bool] {
       return viewModel.userAPP.profile.roles.filter({$0.value})
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            CircleAvatarView(image: image, disable: true) {
                do {}
            }
            
            Text("Здравствуйте, \(name) \(surname)!")
                .font(.body)
                .lineLimit(2)
                .minimumScaleFactor(scaleFactor)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 10)

            VStack(alignment: .center, spacing: 5) {
                if roles.count > 1 {
                UserRoleView(role: $viewModel.userAPP.profile.prefer,
                             select: $viewModel.isFinish,
                             roles: roles)
                }
                
                CustomButton(text: "Продолжить", width: WIDTH * 0.4) {
                    viewModel.isFinish.toggle()
                }
                HorizontalDividerLabelView(label: "или")
                HStack(alignment: .center, spacing: 20) {
                    TextButton(text: "Сменить пользователя") {
                        viewModel.isExit.toggle()
                    }
                    TextButton(text: "Редактировать") {
                        viewModel.showView = .edit
                    }
                }
                
            }
            .padding(.top, hPadding)
        }
        .padding(.all, hPadding)
        .frame(width: WIDTH * 0.95)
        .background(
            Color.accentColor.opacity(0.1).cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor, lineWidth: 1)
                )
        )
        .onChange(of: viewModel.isFinish) { newValue in
            if newValue {
                switch viewModel.userAPP.profile.prefer {
                case .owner:
                    navigation.view = .error
                case .app:
                    navigation.view = .admin
                case .order:
                    navigation.view = .error
                case .stage:
                    navigation.view = .error
                case .admin:
                    navigation.view = .admin
                }
                
            }
        }
    }
}

