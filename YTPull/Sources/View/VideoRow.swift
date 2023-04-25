//
//  VideoRow.swift
//  YTPull
//
//  Created by Huy Nguyen on 11/04/2023.
//
import SwiftUI
import Combine

struct VideoRow: View {

    @State var video: VideoInfo
    @State var mediaType: MediaType
    @StateObject var downloader = Downloader()
    @StateObject var extracter = Extracter()
    @State var alertMessage = ""

    var body: some View {
        VStack {
            HStack {
                AsyncImage(url: URL(string: video.thumbnail)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 160, height: 90)
                VStack(alignment: .leading, spacing: 4, content: {
                    Text(video.fulltitle)
                        .font(.title3)
                        .fontWeight(.medium)
                        .lineLimit(3)
                    Text(video.channel)
                        .font(.subheadline)
                        .fontWeight(.light)
                    switch mediaType {
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
            .background(.black)
            .listRowSeparator(.hidden)
            .clipped()
            .cornerRadius(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            do {
                switch mediaType {
                case .audio:
                    _ = extracter.process(with: video)
                        .subscribe(on: DispatchQueue.main)
                        .sink { completion in
                            if case .failure(let error) = completion {
                                alertMessage = error.localizedDescription
                            }
                        } receiveValue: { _ in }
                case .video:
                    try downloader.start(video)
                case .none:
                    break
                }
            } catch {
                print(error)
            }
        }
    }
}
