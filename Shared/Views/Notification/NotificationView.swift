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
            Color.accentColor.opacity(0.1)
                .ignoresSafeArea()
            
            VStack(alignment: .center){
                
                Image(systemName: "info.circle")
                    .resizable()
                    .foregroundColor(.orange)
                    .frame(width: 30, height: 30)
                    .padding(.vertical, 20)
                Text(text)
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .minimumScaleFactor(0.9)
                    .lineLimit(3)
                HStack(alignment: .center, spacing: 30) {
                    
                    if let button2 = button2 {
                        Button(action: {
                            action2()
                        }, label: {
                            Text(button2)
                                .font(.footnote)
                                .foregroundColor(Color.cyan.opacity(0.8))
                        })
                        .frame(width: WIDTH * 0.25, height: WIDTH * 0.07)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5).stroke(Color.cyan.opacity(0.8), lineWidth: 1)
                        )
                    }
                    
                    Button(action: {
                        action()
                    }, label: {
                        Text(button)
                            .font(.footnote)
                            .foregroundColor(Color.orange.opacity(0.8))
                    })
                    .frame(width: WIDTH * 0.25, height: WIDTH * 0.07)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5).stroke(Color.orange.opacity(0.8), lineWidth: 1)
                    )

                }
                .padding(.vertical, 10)
            }
            .padding(.all, 15)
            .frame(minWidth: WIDTH * 0.8)
            .background(Color.white
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.3),
                        radius: 2, x: 2, y: 2)
            )
        }
    }
}

