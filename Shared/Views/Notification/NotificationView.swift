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
    let action: (() -> Void)

    init(text: String, button: String, action: @escaping (() -> Void)){
        self.text = text
        self.button = button
        self.action = action
    }
    
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

                Button(action: {
                    action()
                }, label: {
                    Text(button)
                        .font(.footnote)
                        .foregroundColor(.orange)
                })
                .frame(width: WIDTH * 0.25, height: WIDTH * 0.07)
                .overlay(
                    RoundedRectangle(cornerRadius: 5).stroke(Color.orange, lineWidth: 1)
                )
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


