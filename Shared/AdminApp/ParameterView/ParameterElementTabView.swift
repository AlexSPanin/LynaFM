//
//  ParameterElementTabView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 13.02.2023.
//

import SwiftUI

struct ParameterElementTabView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: ParameterAdminViewModel
    var card: Int {
        viewModel.card ?? 0
    }
    var count: Int {
        if let card = viewModel.card {
            let count = viewModel.cards[card].elements.count
            return count
        } else {
            return 0
        }
    }
    
    var body: some View {
        VStack {
            ButtonMoveAdd(isMove: $viewModel.isMoveElement, showAdd: $viewModel.showAddElement)
                .padding(.horizontal, hPadding)
                .padding(.bottom, 5)
//                .disabled(viewModel.isEmptyElements)
//                .opacity(viewModel.isEmptyElements ? 0.1 : 1)
            
            Divider()
                .frame(height: 1, alignment: .leading)
                .padding(.horizontal, hPadding)
            if count != 0 {
                List {
                    ForEach(0..<count, id: \.self) { index in
                        Button {
                            viewModel.element = index
                            viewModel.showEditElement.toggle()
                        } label: {
                            let status = viewModel.cards[card].elements[index].isActive
                            let image = viewModel.cards[card].elements[index].images.first
                            
                            HStack(spacing: 2) {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .interpolation(.medium)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: WIDTH * 0.03, alignment: .center)
                                    .foregroundColor(status ? .cyan.opacity(0.8) : .red.opacity(0.8))
                                if let image = image {
                                    RemoteImage(file: image, type: .image)
                                        .frame(width: HEIGHT * 0.045, height: HEIGHT * 0.045, alignment: .center)
                                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.accentColor, lineWidth: 1))
                                        .padding(.leading, 3)
                                }
                                Text(viewModel.cards[card].elements[index].name)
                                    .font(.body)
                                    .lineLimit(2)
                                    .minimumScaleFactor(scaleFactor)
                                    .frame(width: viewModel.isMoveElement ? WIDTH * 0.3 : WIDTH * 0.42, height: HEIGHT * 0.05, alignment: .leading)
                                    .padding(.leading, 3)
                                Text(viewModel.cards[card].elements[index].value)
                                    .font(.footnote)
                                    .lineLimit(3)
                                    .minimumScaleFactor(scaleFactor)
                                    .frame(width: viewModel.isMoveElement ? WIDTH * 0.3 : WIDTH * 0.45, height: HEIGHT * 0.05, alignment: .leading)
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                    .onMove { indexSet, dest in
                        viewModel.moveElements(to: viewModel.card, from: indexSet, to: dest)
                    }
                }
                .listStyle(.plain)
                .padding(.trailing, hPadding)
            }
        }
        .padding(.top, hPadding)
        
        .sheet(isPresented: $viewModel.showAddElement) {
            CreatedParametrElementView(viewModel: viewModel, isEditing: false)
        }
        .sheet(isPresented: $viewModel.showEditElement) {
            CreatedParametrElementView(viewModel: viewModel, isEditing: true)
        }
    }
}
