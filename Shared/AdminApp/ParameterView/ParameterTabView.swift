//
//  ParameterTabView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 13.02.2023.
//

import SwiftUI

struct ParameterTabView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: ParameterAdminViewModel
    var body: some View {
        VStack {
            ButtonMoveAdd(isMove: $viewModel.isMove, showAdd: $viewModel.showAdd)
                .padding(.horizontal, hPadding)
                .padding(.bottom, 5)
            Divider()
                .frame(height: 1, alignment: .leading)
                .padding(.horizontal, hPadding)
            List {
                ForEach(0..<viewModel.cards.count, id: \.self) { index in
                    Button {
                        viewModel.card = index
                        viewModel.showEdit.toggle()
                    } label: {
                        let status = viewModel.cards[index].parameter.isActive
                        let description = viewModel.cards[index].parameter.label.isEmpty ? "" : " - " + viewModel.cards[index].parameter.label
                        let label = viewModel.cards[index].parameter.name + description
                        HStack(spacing: 2) {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .interpolation(.medium)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: WIDTH * 0.03, alignment: .center)
                                .foregroundColor(status ? .cyan.opacity(0.8) : .red.opacity(0.8))
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
            .listStyle(.plain)
            .padding(.trailing, hPadding)
        }
        .padding(.top, hPadding)
        .sheet(isPresented: $viewModel.showAdd) {
            CreatedParameterView(viewModel: viewModel, isEditing: false)
        }
        .sheet(isPresented: $viewModel.showEdit) {
            CreatedParameterView(viewModel: viewModel, isEditing: true)
        }
    }
}
