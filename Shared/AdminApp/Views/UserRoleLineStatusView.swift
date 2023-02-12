//
//  UserRoleLineView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import SwiftUI

struct UserRoleLineStatusView: View {
    let index: Int
    let roles: [String]
    private var label: String {
        UserRole.allCases[index].label
    }
    private var status: Bool {
        let role = UserRole.allCases[index].role
        return roles.contains(where: {$0 == role })
        
    }
    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: hPadding) {
                Image(systemName: "circle.fill")
                    .resizable()
                    .interpolation(.medium)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: WIDTH * 0.03, alignment: .center)
                    .foregroundColor(status ? .cyan.opacity(0.8) : .red.opacity(0.8))
                Text(label)
                    .minimumScaleFactor(0.9)
                    .lineLimit(1)
                Spacer()
            }
            .font(.callout)
        }
        .padding(.horizontal, hPadding)
        .frame(width: WIDTH * 0.9, height: WIDTH * 0.09, alignment: .center)
    }
}

struct UserRoleLineSelectView: View {
    let select: String
    let role: String
    private var status: Bool {
        select == role
    }
    private var label: String? {
        UserRole.allCases.first(where: {$0.role == role})?.label
    }
    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: hPadding) {
                Image(systemName: "circle.fill")
                    .resizable()
                    .interpolation(.medium)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: WIDTH * 0.03, alignment: .center)
                    .foregroundColor(.cyan.opacity(status ? 0.8 : 0))
                Text(label ?? "")
                    .minimumScaleFactor(0.9)
                    .lineLimit(1)
                Spacer()
            }
            .font(.callout)
        }
        .padding(.horizontal, hPadding)
        .frame(width: WIDTH * 0.9, height: WIDTH * 0.09, alignment: .center)
    }
}

