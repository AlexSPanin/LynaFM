//
//  UserRoleView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 04.02.2023.
//

import SwiftUI

struct UserRoleView: View {
    @Binding var role: UserRole
    @Binding var select: Bool
    let roles: [UserRole: Bool]
    var body: some View {
        VStack {
            HStack {
                Text("Роли пользователя:")
                    .font(.footnote)
                    .foregroundColor(.accentColor)
                    .minimumScaleFactor(0.9)
                    .lineLimit(1)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                ForEach(roles.sorted(by: {$0.key.sort < $1.key.sort}), id: \.key.sort) { key, value in
                    Button {
                        role = key
                        select.toggle()
                    } label: {
                        UserRoleLineView(status: value, role: key)
                    }
                    .background(
                        Color.accentColor.opacity(role == key ? 0.1 : 0).cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor.opacity(role == key ? 1 : 0), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
}
