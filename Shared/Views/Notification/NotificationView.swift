//
//  NotificationView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//

import SwiftUI

struct NotificationView: View {
    let text: String
    let button: String
    let button2: String?
    let action: (() -> Void)
    let action2: (() -> Void)
    var body: some View {
        ZStack {
            mainLigth
                .ignoresSafeArea()
            VStack(alignment: .center){
                
                Image(systemName: "info.circle")
                    .resizable()
                    .foregroundColor(mainBack)
                    .frame(width: imageS, height: imageS)
                    .padding(.vertical, hPadding)
                Text(text)
                    .multilineTextAlignment(.center)
                    .font(fontSm)
                    .minimumScaleFactor(scale)
                    .lineLimit(3)
                HStack(alignment: .center, spacing: 30) {
                    
                    if let button2 = button2 {
                        Button(action: {
                            action2()
                        }, label: {
                            Text(button2)
                                .font(fontSm)
                                .foregroundColor(mainRigth)
                        })
                        .frame(width: screen * 0.25, height: screen * 0.07)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5).stroke(mainRigth, lineWidth: 1)
                        )
                    }
                    
                    Button(action: {
                        action()
                    }, label: {
                        Text(button)
                            .font(fontSm)
                            .foregroundColor(mainBack)
                    })
                    .frame(width: screen * 0.25, height: screen * 0.07)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5).stroke(mainBack, lineWidth: 1)
                    )

                }
                .padding(.vertical, 10)
            }
            .padding(.all, 15)
            .frame(minWidth: screen * 0.8)
            .background(Color.white
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.3),
                        radius: 2, x: 2, y: 2)
            )
        }
    }
}

