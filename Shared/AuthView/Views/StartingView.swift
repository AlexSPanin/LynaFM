//
//  StartingView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct StartingView: View {
    @EnvironmentObject var navigation: NavigationViewModel
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isFinish = false
    @State private var roles = ""
    
    private var user: UserAPP {
        return viewModel.currentUser ?? UserAPP()
    }
    private var name: String {
        viewModel.currentUser?.name ?? ""
    }
    private var surname: String {
        viewModel.currentUser?.surname ?? ""
    }

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            CircleAvatarView(image: viewModel.photo, disable: true) {
                do {}
            }
            
            Text("Здравствуйте, \(name) \(surname)!")
                .font(.body)
                .lineLimit(2)
                .minimumScaleFactor(scale)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 10)

            VStack(alignment: .center, spacing: 5) {
                if user.roles.count > 1 {
                    UserRoleView(select: $roles, roles: user.roles)
                        .padding(.vertical, hPadding)
                }
                
                CustomButton(text: TypeMessage.enter.label, width: screen * 0.4) {
                    isFinish.toggle()
                }
                HorizontalDividerLabelView(label: TypeMessage.or.label)
                HStack {
                    Spacer()
                    TextButton(text: "Сменить пользователя",
                               size: screen * 0.35,
                               color: mainColor) {
                        viewModel.isExit.toggle()
                    }
                    Spacer()
                    TextButton(text: "Редактировать",
                               size: screen * 0.35,
                               color: mainColor) {
                        viewModel.showView = .edit
                    }
                    Spacer()
                }
                
            }
            .padding(.top, hPadding)
        }
        .padding(.all, hPadding)
        .frame(width: screen)
        .background(
            mainLigth.cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(mainColor, lineWidth: 1)
                )
        )
        .onChange(of: isFinish) { newValue in
            if newValue, let role = UserRole.allCases.first(where: {$0.role == user.role}) {
                switch role {
                case .owner:
                    navigation.showView = .error
                case .app:
                    navigation.showView = .admin
                case .order:
                    navigation.showView = .error
                case .stage:
                    navigation.showView = .error
                case .admin:
                    navigation.showView = .admin
                }
                
            }
        }
        .onChange(of: roles) { newValue in
            viewModel.currentUser?.role = roles
            viewModel.isChange = true
        }
        .onAppear{
            roles = user.role
        }
        
    }
}

