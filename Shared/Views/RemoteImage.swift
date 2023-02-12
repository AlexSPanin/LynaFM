//
//  RemoteImage.swift
//  LynaFM (iOS)
//
//  Created by Александр Панин on 11.02.2023.
//

import SwiftUI
import Combine

//MARK: - загрузка изображения или из памяти либо из сети
struct RemoteImage: View {
    @ObservedObject var image: RemoteImageURL
    @State private var isHiden: Bool = false
    private var isLoding: Bool {
        image.data != Data()
    }
    
    init(file: String, type: UploadType) {
        image = RemoteImageURL(file: file, type: type)
    }
    var body: some View {
        ZStack {
            if let data = image.data, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.medium)
                    .aspectRatio(contentMode: .fit)
                    .opacity(isHiden ? 0 : 1)
            } else {
                ProgressView()
            }
        }
        .onChange(of: isLoding) { newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                self.isHiden.toggle()
            }
        }
    }
}

class RemoteImageURL: ObservableObject {
    var didChange = PassthroughSubject<Data?, Never>()
    @Published var data: Data? {
        didSet {
            didChange.send(data)
        }
    }
    init(file: String, type: UploadType) {
        FileAppManager.shared.loadFileData(to: file, type: .assets) { data in
            if let data = data {
                self.data = data
            } else {
                DispatchQueue.main.async {
                    NetworkManager.shared.loadFile(type: type, name: file) { result in
                        switch result {
                        case .success(let data):
                            print("Файл загружен начало сохранения в памяти \(file)")
                            FileAppManager.shared.saveFileData(to: file, type: .assets, data: data)
                            self.data = data
                        case .failure(_):
                            print("ОШИБКА загрузки из сети файла \(file)")
                            self.data = nil
                        }
                    }
                }
            }
        }
    }
}
