//
//  UserRoleView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 04.02.2023.
//

import SwiftUI

struct UserRoleView: View {
    @Binding var select: String
    let roles: [String]
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Роли пользователя:")
                    .font(.body)
                    .foregroundColor(.accentColor)
                Spacer()
            }
            List(roles, id: \.self) { role in
                Button {
                    select = role
                } label: {
                    UserRoleLineSelectView(select: select, role: role)
                }
                .listRowBackground(Color.accentColor.opacity(0.1))
            }
            .listStyle(.plain)
            .frame(height: HEIGHT * 0.3)
        }
    }
}
