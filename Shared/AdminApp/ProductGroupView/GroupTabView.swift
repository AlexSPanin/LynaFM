//
//  GroupTabView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 18.02.2023.
//

import SwiftUI

struct GroupTabView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: GroupAdminViewModel
    var body: some View {
        VStack {
            ButtonMoveAdd(isMove: $viewModel.isMove, showAdd: $viewModel.showAdd)
                .padding(.horizontal, hPadding)
                .padding(.bottom, 5)
            Divider()
                .frame(height: 1, alignment: .leading)
                .padding(.horizontal, hPadding)
            List {
                ForEach(TypeGroup.allCases, id: \.self ) { type in
                    let typeCards = viewModel.cards.filter({$0.type == type.label}).sorted(by: {$0.sort < $1.sort})
                    Section(type.label) {
                        ForEach(typeCards, id: \.id) { card in
                            Button {
                                viewModel.card = card
                                viewModel.showEdit.toggle()
                            } label: {
                                let status = card.isActive
                                let image = card.image
                                let description = card.label.isEmpty ? "" : " - " + card.label
                                let label = card.name + description
                                HStack(spacing: 2) {
                                    
                                    Image(systemName: "circle.fill")
                                        .resizable()
                                        .interpolation(.medium)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: WIDTH * 0.03, alignment: .center)
                                        .foregroundColor(status ? .cyan.opacity(0.8) : .red.opacity(0.8))
                                    
                                    if !image.isEmpty {
                                        RemoteImage(file: image, type: .image)
                                            .frame(width: HEIGHT * 0.045, height: HEIGHT * 0.045, alignment: .center)
                                            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.accentColor, lineWidth: 1))
                                            .padding(.leading, 5)
                                    }
                                    Text(label)
                                        .font(.body)
                                        .lineLimit(3)
                                        .minimumScaleFactor(scale)
                                        .frame(width: viewModel.isMove ? WIDTH * 0.65 : WIDTH * 0.85, height: HEIGHT * 0.05, alignment: .leading)
                                        .padding(.leading, 5)
                                }
                                .foregroundColor(.accentColor)
                            }
                        }
                        .onMove { indexSet, dest in
                            viewModel.move(from: indexSet, to: dest)
                        }
                    }
                }
                
            }
            .listStyle(.plain)
            .padding(.trailing, hPadding)
        }
        .padding(.top, hPadding)
        .sheet(isPresented: $viewModel.showAdd) {
            CreatedGroupView(viewModel: viewModel, isEditing: false)
        }
        .sheet(isPresented: $viewModel.showEdit) {
            CreatedGroupView(viewModel: viewModel, isEditing: true)
        }
    }
}
