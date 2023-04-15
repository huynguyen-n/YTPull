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
    @State var downloadAmount: Float = 0.0

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
                    Text(String(format: "%.1f%%", downloadAmount))
                        .font(.caption2)
                        .fontWeight(.light)
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
            try? extractAudio()
        }
    }

    private func extractAudio() throws {
        guard let url = video._url else {
            throw ExtractError.urlInvalidation
        }
        var store = [AnyCancellable]()
        var export: Export?

        Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                guard let progress = export?.exportSession.progress, progress > 0.5 else {
                    downloadAmount += 0.1
                    return
                }
                downloadAmount = progress * 100
            })
            .store(in: &store)

        let extract = ExtractImpl(url: url)
        extract.process { callBackComposition in
            do {
                let composition = try callBackComposition()
                export = Export(composition: composition, fileName: video.fulltitle)
                export?.process { isSuccess, error in
                    store.removeAll()
                    guard isSuccess else {
                        return
                    }
                    downloadAmount = 100
                }
            } catch let error {
                print(error)
            }
        }
    }
}

struct VideoRow_Previews: PreviewProvider {
    static var previews: some View {
        VideoRow(video: .dummy(), mediaType: .none)
    }
}
