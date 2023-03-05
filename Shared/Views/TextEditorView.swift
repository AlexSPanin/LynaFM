
//
//  TextEditorView.swift
//  ShagameCom
//
//  Created by Dmitrii Onegin on 31.03.2022.
//

import SwiftUI

struct TextEditorView: View {
    
    let subtitle: String
    let height : CGFloat
    
    @Binding var text: String
    
    init(subtitle: String, height : CGFloat, text: Binding<String>) {
        UITextView.appearance().backgroundColor = .clear
        self.subtitle = subtitle
        self.height = height
        self._text = text
    }
    
    var body: some View {

        VStack(alignment: .leading, spacing: 3){
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.accentColor)
            
            TextEditor(text: $text)
                .submitLabel(.continue)
                .multilineTextAlignment(.leading)
                .disableAutocorrection(false)
                .textInputAutocapitalization(.none)
                .font(.body)
                .foregroundColor(.accentColor)
                .lineLimit(/*@START_MENU_TOKEN@*/3/*@END_MENU_TOKEN@*/)
                .frame(height: height)
        }
        .padding(.all, 5)
        .background(
            RoundedRectangle(cornerRadius: 2)
                .strokeBorder(lineWidth: 1)
                .foregroundColor(.accentColor)
        )
    }
}
