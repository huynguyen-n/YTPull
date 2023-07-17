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
            .background(.black)
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
            if isHovered && !video.storedURL.isEmpty {
                ZStack(alignment: .center) {
                    Color.black.opacity(0.5).frame(maxWidth: .infinity, maxHeight: .infinity)

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
        VStack(alignment: .leading, spacing: 4, content: {
            Text(video.title)
                .font(.title3)
                .fontWeight(.medium)
                .lineLimit(3)
            Text(video.channel)
                .font(.subheadline)
                .fontWeight(.light)
            switch MediaType(video.type) {
            case .audio:
                if !alertMessage.isEmpty {
                    Text(String(format: alertMessage, extracter.progress))
                        .font(.caption2)
                        .fontWeight(.light)
                        .foregroundColor(Color.red)
                } else {
                    Text(String(format: "%.1f%%", extracter.progress))
                        .font(.caption2)
                        .fontWeight(.light)
                }
            case .video:
                Text(String(format: "%.1f%%", downloader.progress))
                    .font(.caption2)
                    .fontWeight(.light)
            case .none:
                EmptyView()
            }
        })
        .padding(.trailing)
        Spacer()
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