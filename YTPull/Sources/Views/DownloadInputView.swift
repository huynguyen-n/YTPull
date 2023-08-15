//
//  DownloadInputView.swift
//  YTPull
//
//  Created by Huy Nguyen on 30/06/2023.
//

import Combine
import SwiftUI

struct DownloadInputView: View {
    @ObservedObject var viewModel: DownloadInputViewModel

    var body: some View {
        VStack {
            Text(viewModel.url.isEmpty ? "Please copy a Youtube URL" : viewModel.url)
                .font(.title3)

            #if DEBUG
            Button(action: viewModel.randomURL) {
                Text("Random URL")
                    .controlSize(.regular)
            }.disabled(mockYTURL.isEmpty)
            #endif

            HStack {
                Picker("Type", selection: $viewModel.media) {
                    let medias = MediaType.allCases
                    ForEach(0..<medias.count, id: \.self) { index in
                        let value = medias[index].value
                        Text(value).tag(medias[index])
                    }
                }
                .frame(maxWidth: 100)
                .labelsHidden()
                .disabled(viewModel.videoInfo == nil)
                HStack {
                    Spacer()
                    HStack {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(.circular).scaleEffect(0.6)
                        } else {
                            Image("youtube-squared").resizable().scaledToFit()
                        }
                    }
                    .frame(maxHeight: 48)
                    Spacer()
                }
                Button(action: viewModel.didTapDownload) {
                    Text("Download")
                        .frame(width: 100)
                }
                .disabled(viewModel.isDisabled)
            }
            if !viewModel.errorMessage.isEmpty  {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding([.horizontal, .top])
    }
}

struct DownloadInputView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadInputView(viewModel: .init())
    }
}

final class DownloadInputViewModel: ObservableObject {
    @Published var url: String = ""
    @Published var media: MediaType = .none
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isDisabled: Bool = true
    @Published var errorMessage: String = ""

    var videoInfo: VideoInfo?
    let store: VideoStore = VideoStore.shared
    private var cancellables: [AnyCancellable] = []

    init(media: MediaType = .none, isLoading: Bool = false) {
        self.media = media
        self.isLoading = isLoading
        self.binding()
        #if DEBUG
        store.removeAllVideos()
        #endif
    }

    private func binding() {
        $url.sink { [weak self] strURL in
            guard let self else { return }
            guard strURL.buildYTURL != nil else { return }
            self.processURL()
        }.store(in: &cancellables)

        $media.sink { [weak self] value in
            guard let self, let video = self.videoInfo else { return }
            let isEmpty = (try? self.store.allVideos())?.compactMap { $0 }.filter { $0.id == video.id && value == MediaType($0.type) }.isEmpty ?? false
            self.isDisabled = !isEmpty || value == .none
        }.store(in: &cancellables)
    }

    func processURL() {
        excuteBestMedia { videoInfo in
            self.videoInfo = videoInfo
            NSPasteboard.general.clearContents()
        }
    }

    func didTapDownload() {
        guard let videoInfo else {
            return
        }
        store.storeVideo(id: videoInfo.id,
                         title: videoInfo.fulltitle,
                         channel: videoInfo.channel,
                         url: videoInfo.url,
                         thumbnail: videoInfo.thumbnail,
                         type: media)
        reset()
    }

    #if DEBUG
    func randomURL() {
        guard let url = mockYTURL.randomElement() else {
            return
        }
        mockYTURL.removeAll(where: { $0 == url })
        self.url = url
    }
    #endif

    private func reset() {
        videoInfo = nil
        url = ""
        media = .none
        isDisabled = true
    }

    private func excuteBestMedia(completion: @escaping (VideoInfo?) -> Void) {
        isLoading = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isLoading = false
            let command = Commands.YTDLP.bestMedia.execute(for: self.url)
            if let error = command.error {
                self.errorMessage = error.isEmpty ? command.errorLocalization : error
            }
            completion(command.data.videoInfo)
        }
    }
}

private extension Data? {
    var videoInfo: VideoInfo? {
        guard let self else {
            return nil
        }
        return try? JSONDecoder().decode(VideoInfo.self, from: self)
    }
}
