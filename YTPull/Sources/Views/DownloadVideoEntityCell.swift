//
//  DownloadVideoEntityCell.swift
//  YTPull
//
//  Created by Huy Nguyen on 04/07/2023.
//

import SwiftUI
import AppKit

struct DownloadVideoEntityCell: View {
    let managedObject: NSManagedObject

    var body: some View {
        _DownloadVideoCell(entity: Entity(managedObject))
    }
}

private struct _DownloadVideoCell: View {
    let entity: Entity

    var body: some View {
        switch entity {
        case .video(let videoEntity):
            return DownloadVideoCell(video: videoEntity)
        }
    }
}

private struct DownloadVideoCell: View {
    let video: VideoEntity
    @StateObject private var downloader: Downloader = Downloader()
    @StateObject private var extracter: Extracter = Extracter()
    @State private var alertMessage = ""
    @State private var isHovered = false
    private let buttonImageFontSize: CGFloat = 32.0

    var body: some View {
        VStack {
            HStack {
                image
                content
            }
            .background(Color(NSColor.underPageBackgroundColor))
            .listRowSeparator(.hidden)
            .clipped()
            .cornerRadius(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task {
            guard video.storedURL.isEmpty else { return }
            switch MediaType(video.type) {
            case .audio:
                _ = extracter.process(with: video)
                    .subscribe(on: DispatchQueue.main)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            alertMessage = error.localizedDescription
                        }
                    } receiveValue: { _ in }
            case .video:
                try? downloader.start(video)
            case .none:
                break
            }
        }
        .onHover { isHovered = $0 }
    }

    @ViewBuilder
    private var image: some View {
        ZStack {
            ImageLoadingView(url: video.thumbnail)
            HStack {
                VStack {
                    Spacer()
                    Text(MediaType(video.type).value.lowercased())
                        .padding(4)
                        .font(.caption)
                        .background(.red)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            progressViews
            if isHovered && !video.storedURL.isEmpty {
                ZStack(alignment: .center) {
                    Color(nsColor: .underPageBackgroundColor).opacity(0.5).frame(maxWidth: .infinity, maxHeight: .infinity)

                    HStack {
                        Button {
                            guard let url = URL(string: video.storedURL) else { return }
                            NSWorkspace.shared.activateFileViewerSelecting([url])
                        } label: {
                            Image(systemName: "folder.circle.fill")
                                .font(.system(size: buttonImageFontSize))
                        }
                        .buttonStyle(.plain)

                        Button {
                            VideoStore.shared.removeVideo(video)
                        } label: {
                            Image(systemName: "xmark.bin.circle.fill")
                                .font(.system(size: buttonImageFontSize))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(width: 160, height: 90)
    }

    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(video.title)
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(3)
            Text(video.channel)
                .font(.subheadline)
                .fontWeight(.light)
        }
        .padding(.trailing)
        Spacer()
    }

    @ViewBuilder
    private var progressViews: some View {
        let emptyView = EmptyView()
        let total: CGFloat = 100.0
        let type = MediaType(video.type)
        switch type {
        case .audio:
            let progress = extracter.progress
            if progress == total {
                emptyView
            } else {
                ProgressView(value: progress, total: total)
                    .progressViewStyle(.circular)
                    .tint(Color(NSColor.controlBackgroundColor))
            }
        case .video:
            let progress = downloader.progress
            if progress == total {
                emptyView
            } else {
                ProgressView(value: progress, total: total)
                    .progressViewStyle(.circular)
                    .tint(Color(NSColor.controlBackgroundColor))
            }
        case .none:
            emptyView
        }
    }
}

struct DownloadVideoCell_Previews: PreviewProvider {
    static var previews: some View {
        DownloadVideoCell(video: .init())
    }
}

private enum Entity {
    case video(VideoEntity)

    init(_ entity: NSManagedObject) {
        if let video = entity as? VideoEntity {
            self = .video(video)
        } else {
            fatalError("Unsupported entity: \(entity)")
        }
    }
}
