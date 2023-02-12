//
//  UserRoleLineView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 28.01.2023.
//

import SwiftUI

struct UserStageLineStatusView: View {
    let index: Int
    let strings: [String]
    let stages: [ProductionStage]
    
    private var label: String {
        stages[index].name
    }
    private var status: Bool {
        let name = stages[index].name
        return strings.contains(where: {$0 == name })
        
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
                Text(label)
                    .minimumScaleFactor(0.9)
                    .lineLimit(1)
                Spacer()
            }
            .font(.callout)
        }
        .padding(.horizontal, hPadding)
    }
}

struct UserRoleLineStatusView: View {
    let index: Int
    let strings: [String]
    private var label: String {
        UserRole.allCases[index].label
    }
    private var status: Bool {
        let role = UserRole.allCases[index].role
        return strings.contains(where: {$0 == role })
        
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
                Text(label)
                    .minimumScaleFactor(0.9)
                    .lineLimit(1)
                Spacer()
            }
            .font(.callout)
        }
        .padding(.horizontal, hPadding)
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
    }
}

