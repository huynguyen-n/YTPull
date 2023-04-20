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

    @State private var url: String = "https://www.youtube.com/watch?v=_AASUaRyX-8"
    @State private var videos: [VideoInfo] = []
    @State private var selectedMeida: MediaType = .none
    @State private var videoInfo: VideoInfo?
    @State private var isLoading: Bool = false

    // https://www.youtube.com/watch?v=_AASUaRyX-8&ab_channel=LululolaCoffee%2B
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
                .onChange(of: url, perform: { newValue in
                    loadURL()
                })
                .textFieldStyle(.roundedBorder)

                HStack {
                    Picker("", selection: $selectedMeida) {
                        let medias = MediaType.allCases
                        ForEach(0..<medias.count, id: \.self) { index in
                            let value = medias[index].value
                            if !value.isEmpty {
                                Text(value).tag(medias[index])
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
                            } else {
                                Image("youtube-squared").resizable().scaledToFit()
                            }
                        }
                        .frame(maxHeight: 48)
                        Spacer()
                    }
                    Button(action: didTapGetURL) {
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

    private func didTapGetURL() {
        guard let videoInfo = videoInfo else {
            return
        }
        videos.append(videoInfo)
    }

    private func reset() {
        url = ""
        videoInfo = nil
        selectedMeida = .none
    }

    private func loadURL() {
        guard url.isValid else {
            return
        }
        isLoading = true
        DispatchQueue.main.async {
            do {
                Commands.Permission.ytdlp.execute()
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
