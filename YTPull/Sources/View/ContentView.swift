//
//  ContentView.swift
//  YTPull
//
//  Created by Huy Nguyen on 04/04/2023.
//

import SwiftUI
import AVFoundation
import Combine

struct ContentView: View {

    #if DEBUG
    @State private var url: String = "https://www.youtube.com/shorts/OlKUD-dJulM"
    #else
    @State private var url: String = ""
    #endif

    @State private var videos: [VideoInfo] = []
    @State private var selectedMeida: MediaType = .none
    @State private var videoInfo: VideoInfo?
    @State private var isLoading: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack {
            VStack {
                TextField("Paste YouTube URL here", text: $url) { isStarted in
                    videoInfo = nil
                    selectedMeida = .none
                    guard !isStarted else {
                        return
                    }
                    loadURL()
                }
                .textFieldStyle(.roundedBorder)

                HStack {
                    Picker("", selection: $selectedMeida) {
                        let medias = MediaType.allCases
                        ForEach(0..<medias.count, id: \.self) { index in
                            let value = medias[index].value
                            if !value.isEmpty {
                                Text(value).tag(medias[index])
                            } else {
                                EmptyView()
                            }
                        }
                    }
                    .frame(maxWidth: 100)
                    .labelsHidden()
                    HStack {
                        Spacer()
                        HStack {
                            if isLoading {
                                ProgressView().progressViewStyle(.circular).scaleEffect(0.6)
                            } else if alertMessage.isEmpty {
                                Image("youtube-squared").resizable().scaledToFit()
                            } else {
                                Text(alertMessage)
                                    .foregroundColor(Color.red)
                            }
                        }
                        .frame(maxHeight: 48)
                        Spacer()
                    }
                    Button(action: didTapDownload) {
                        Text("Download")
                            .frame(maxWidth: 100)
                    }
                }
                .disabled(videoInfo == nil)
            }
            .padding([.horizontal, .top])
            List(videos) { video in
                VideoRow(video: video, mediaType: selectedMeida)
            }
            .frame( maxWidth: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
    }

    enum VideoInfoError: Error, LocalizedError {
        case invalidData
        case alreadyDownload
    }

    private func validateVideo() throws -> VideoInfo {
        guard let videoInfo else {
            throw VideoInfoError.invalidData
        }

        guard !videos.contains(where: { $0.id == videoInfo.id }) else {
            throw VideoInfoError.alreadyDownload
        }

        return videoInfo
    }

    private func didTapDownload() {
        do {
            let _videoInfo = try validateVideo()
            videos.append(_videoInfo)
            url = ""
            videoInfo = nil
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    private func loadURL() {
        guard url.isValid else {
            return
        }
        isLoading = true
        DispatchQueue.main.async {
            do {
                let bestMedia = Commands.YTDLP.bestMedia.execute(for: url)
                if let data = bestMedia.data {
                    videoInfo = try JSONDecoder().decode(VideoInfo.self, from: data)
                    selectedMeida = .audio
                }
                isLoading = false
            } catch {
                print("error \(error)")
                isLoading = false
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
