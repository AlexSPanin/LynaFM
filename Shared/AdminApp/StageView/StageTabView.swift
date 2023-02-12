//
//  StageTabView.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 11.02.2023.
//

import SwiftUI

struct StageTabView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: StageAdminViewModel
    
    var body: some View {
        VStack {
            HStack {
                
                Button {
                    viewModel.isMove.toggle()
                    if viewModel.isMove {
                        self.editMode?.wrappedValue = .active
                    } else {
                        self.editMode?.wrappedValue = .inactive
                    }
                } label: {
                    if viewModel.isMove {
                        Text("OK")
                            .font(.body)
                            .foregroundColor(.cyan.opacity(0.8))
                        
                    } else {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .resizable()
                        .interpolation(.medium)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.cyan.opacity(0.8))
                        .frame(width: WIDTH * 0.05, alignment: .center)
                    }
                    
                }
                Spacer()
                Button {
                    viewModel.showAdd.toggle()
                } label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .interpolation(.medium)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.cyan.opacity(0.8))
                        .frame(width: WIDTH * 0.05, alignment: .center)
                    
                }
                .disabled(viewModel.isMove)
                .opacity(viewModel.isMove ? 0 : 1)
                
            }
            .padding(.horizontal, hPadding)
            .padding(.bottom, 5)
            
            
            List {
                ForEach(0..<viewModel.cards.count, id: \.self) { index in
                    Button {
                        viewModel.card = viewModel.cards[index]
                        viewModel.showEdit.toggle()
                    } label: {
                        let name = String("\(viewModel.cards[index].name)")
                        let status = viewModel.cards[index].isActive
                        HStack(spacing: 2) {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .interpolation(.medium)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: WIDTH * 0.03, alignment: .center)
                                .foregroundColor(status ? .cyan.opacity(0.8) : .red.opacity(0.8))
                            Text(name)
                                .font(.body)
                                .lineLimit(2)
                                .minimumScaleFactor(scaleFactor)
                                .frame(width: viewModel.isMove ? WIDTH * 0.35 : WIDTH * 0.4, height: HEIGHT * 0.1, alignment: .leading)
                                .padding(.leading, 5)
                            Text(viewModel.cards[index].label)
                                .font(.footnote)
                                .lineLimit(3)
                                .minimumScaleFactor(scaleFactor)
                                .frame(width: viewModel.isMove ? WIDTH * 0.35 : WIDTH * 0.4, height: HEIGHT * 0.1, alignment: .leading)
                        }
                        
                        .foregroundColor(.accentColor)
                    }
                }
                .onMove { indexSet, dest in
                    viewModel.move(from: indexSet, to: dest)
                }
                
            }
            .listStyle(.plain)
            .frame(height: HEIGHT * 0.6)
        }
        .padding(.top, hPadding)
        .sheet(isPresented: $viewModel.showAdd) {
            CreatedStageView(viewModel: viewModel, isEditing: false)
        }
        .sheet(isPresented: $viewModel.showEdit) {
            CreatedStageView(viewModel: viewModel, isEditing: true)
        }
    }
}


