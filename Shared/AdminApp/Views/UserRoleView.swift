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
                ForEach(0..<roles.count, id: \.self) { index in
                    Button {
                        select = roles[index]
                    } label: {
                        UserRoleLineSelectView(select: select, role: roles[index])
                    }
                }
            }
        }
    }
}
