//
//  DownloadListView.swift
//  YTPull
//
//  Created by Huy Nguyen on 03/07/2023.
//

import SwiftUI
import Combine

struct DownloadListView: View {

    @ObservedObject private(set) var viewModel: DownloadListViewViewModel = .init()

    var body: some View {
        List {
            ForEach(viewModel.videos, id: \.objectID, content: DownloadVideoEntityCell.init)
        }
        .frame(maxWidth: .infinity)
        .edgesIgnoringSafeArea(.all)
        .scrollContentBackground(.hidden)
        .overlay(overlayView)
    }

    @ViewBuilder
    var overlayView: some View {
        if viewModel.videos.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "airplayvideo").font(.system(size: 32))
                Text("No Videos").font(.title)
                Text("Copy URL and open YTPull to download").font(.subheadline).foregroundStyle(.gray)
            }
        } else {
            EmptyView()
        }
    }
}

struct DownloadListView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadListView(viewModel: .init())
    }
}

final class DownloadListViewViewModel: ObservableObject {
    @Published private(set) var videos: [VideoEntity] = []
    private let store: VideoStore = .shared
    private let videosObserver: ManagedObjectsObserver<VideoEntity>
    private var cancellables: [AnyCancellable] = []

    init() {
        if let videos = try? store.allVideos() {
            self.videos = videos
        }
        self.videosObserver = .videos(for: store.viewContext)

        videosObserver.$objects.dropFirst().sink { [weak self] videos in
            guard let self = self else { return }
            withAnimation {
                if videos.count == self.videos.count - 1 { // remove a video
                    self.videos = videos.sorted(by: { $0.createdAt > $1.createdAt })
                }
                guard let latestVideo = videos.first, latestVideo.storedURL.isEmpty else { return }
                self.videos.append(latestVideo)
                self.videos = self.videos.sorted(by: { $0.createdAt > $1.createdAt })
                URLCache.shared.memoryCapacity = 1024 * self.videos.count
            }
        }.store(in: &cancellables)
    }
}
