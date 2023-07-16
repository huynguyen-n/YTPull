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
            TextField("YouTube URL", text: $viewModel.url)
                .textFieldStyle(.roundedBorder)

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
                HStack {
                    Spacer()
                    HStack {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(.circular).scaleEffect(0.6)
                        } else if !viewModel.errorMessage.isEmpty  {
                            Text(viewModel.errorMessage).foregroundColor(.red)
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
                .disabled(viewModel.media == .none)
            }
            .disabled(viewModel.videoInfo == nil)
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
    @Published private(set) var isDisabled: Bool = false
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
            guard strURL.isValid else { return }
            self.processURL()
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
    }

    private func excuteBestMedia(completion: @escaping (VideoInfo?) -> Void) {
        isLoading = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isLoading = false
            let command = Commands.YTDLP.bestMedia.execute(for: self.url)
            self.errorMessage = command.error ?? ""
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

private extension String {
    var isValid: Bool {
        let regex = "(http(s)?:\\/\\/)?(www\\.|m\\.)?youtu(be\\.com|\\.be)(\\/watch\\?([&=a-z]{0,})(v=[\\d\\w]{1,}).+|\\/[\\d\\w]{1,})"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
}
