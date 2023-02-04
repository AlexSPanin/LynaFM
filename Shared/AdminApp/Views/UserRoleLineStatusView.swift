//
//  UserRoleLineView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import SwiftUI

struct UserRoleLineStatusView: View {
    let status: Bool
    let role: UserRole
    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: hPadding) {
                Image(systemName: "circle.fill")
                    .resizable()
                    .interpolation(.medium)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: WIDTH * 0.03, alignment: .center)
                    .foregroundColor(status ? .green : .red)
                Text("\(role.label)")
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
    let status: Bool
    let role: UserRole
    var body: some View {
        VStack(spacing: 1) {
            HStack(spacing: hPadding) {
                Image(systemName: "circle.fill")
                    .resizable()
                    .interpolation(.medium)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: WIDTH * 0.03, alignment: .center)
                    .foregroundColor(.green.opacity(status ? 1 : 0))
                Text("\(role.label)")
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

