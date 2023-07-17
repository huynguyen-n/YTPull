//
//  ImageLoadingView.swift
//  YTPull
//
//  Created by Huy Nguyen on 08/07/2023.
//

import SwiftUI

enum ImageLoaderError: Error {
    case badURL
    case badResponse(code: Int)
    case unknown
}

struct ImageLoadingView: View {
    @StateObject var imageLoader: ImageLoader

    init(url: String?) {
        self._imageLoader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let errorMessage = imageLoader.errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .onAppear {
            try? imageLoader.fetch()
        }
    }
}

final class ImageLoader: ObservableObject {
    let url: String?
    @Published var image: NSImage? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    init(url: String?) {
        self.url = url
    }

    func fetch() throws {
        guard image == nil, !isLoading else { return }

        guard let url, let fetchURL = URL(string: url) else {
            throw ImageLoaderError.badURL
        }

        isLoading.toggle()
        let request = URLRequest(url: fetchURL, cachePolicy: .returnCacheDataElseLoad)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading.toggle()
                if let error {
                    self.errorMessage = error.localizedDescription
                } else if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                    self.errorMessage = ImageLoaderError.badResponse(code: response.statusCode).localizedDescription
                } else if let data, let image = NSImage(data: data) {
                    self.image = image
                } else {
                    self.errorMessage = ImageLoaderError.unknown.localizedDescription
                }
            }
        }
        task.resume()
    }
}
