//
//  TextFieldView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 19.01.2023.
//
import SwiftUI


enum TypeTextField {
    case password
    case login
    case userName
    case simple
}

struct TextFieldView: View {
    
    let subtitle: String
    let tipeTextField: TypeTextField
    
    @Binding var text: String
    @Binding var passwordEnter: String
    
    @State private var isEye = false
    
    init(subtitle: String, tipeTextField: TypeTextField, text: Binding<String>) {
        self.subtitle = subtitle
        self.tipeTextField = tipeTextField
        self._text = text
        self._passwordEnter = text
    }
    
    init(subtitle: String, tipeTextField: TypeTextField, text: Binding<String>, passwordEnter: Binding<String>) {
        self.subtitle = subtitle
        self.tipeTextField = tipeTextField
        self._text = text
        self._passwordEnter = passwordEnter
    }
    
    var body: some View {
        HStack(spacing: 12){
           
            VStack(alignment: .leading, spacing: 3){
                Text(subtitle)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(scaleFactor)
                HStack(spacing: 2) {
                    
                    if tipeTextField == .password {
                        Button {
                            isEye.toggle()
                        } label: {
                            Image(systemName: isEye ? "eye" : "eye.slash")
                                .foregroundColor(.accentColor)
                        }
                    }
                    
                if !isEye && tipeTextField == .password {
                    SecureField("", text: $text)
                        .font(.footnote)
                        .autocapitalization(.none)
                        .frame(height: scaleWidth * 14)
                        
                } else {
                    TextField("", text: $text)
                        .font(.footnote)
                        .autocapitalization(.none)
                        .frame(height: scaleWidth * 14)
                }
                }
            }
            Spacer()
            
            switch tipeTextField {
            case .login:
                if text.count > 5 && text.contains("@") && text.contains(".") {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            case .password:
                if text.count > 5 && passwordEnter == text {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            case .userName:
                if text.count > 3  {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            default:
                do {}
            }
            
        }
        .padding(.all, 10)
//        .padding(.top, 12)
//        .padding(.bottom, 15)
        .background(
            RoundedRectangle(cornerRadius: 2)
                .strokeBorder(lineWidth: 1)
                .foregroundColor(.accentColor))
    }
}
