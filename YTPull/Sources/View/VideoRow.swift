//
//  VideoRow.swift
//  YTPull
//
//  Created by Huy Nguyen on 11/04/2023.
//
import SwiftUI

struct VideoRow: View {

    @State var video: VideoInfo
    @State private var selectedFormatIndex = 0
    @State private var mediaFormatURL = ""

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: video.thumbnail)) { result in
                result.image?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .frame(maxWidth: 100)
            VStack(alignment: .leading, spacing: 4, content: {
                Text(video.fulltitle)
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineLimit(1)
                Text(video.channel)
                    .font(.subheadline)
                    .fontWeight(.light)
            })
            VStack {
                Picker("", selection: $selectedFormatIndex) {
                    ForEach(0..<video.formats.count) {
                        Text(video.formats[$0].ext)
                    }
                }
                Button("Download") {
                    print(video.formats[selectedFormatIndex].url)
                }
            }
            .frame(maxWidth: 100)
            .padding(.all, 4)
        }
        .background(.black)
        .listRowSeparator(.hidden)
        .clipped()
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
    }
}

struct VideoRow_Previews: PreviewProvider {
    static var previews: some View {
        VideoRow(video: VideoInfo.dummy())
    }
}
