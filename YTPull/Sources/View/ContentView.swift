//
//  ContentView.swift
//  YTPull
//
//  Created by Huy Nguyen on 04/04/2023.
//

import SwiftUI

struct ContentView: View {

    @State private var url: String = "https://www.youtube.com/watch?v=tPEE9ZwTmy0"
    @State private var videos: [VideoInfo] = []

    var body: some View {
        VStack {
            TextField("https://www.youtube.com", text: $url)
            Button("Get Video Info", action: didTapGetURL).disabled(!url.isValid)
            List(videos) { video in
                VideoRow(video: video)
            }
            .frame( maxWidth: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
        .padding()
    }

    private func didTapGetURL() {
        do {
            let data = try Execute.shared.excute(["-f", "bv/ba", "-j", url])
            let video = try JSONDecoder().decode(VideoInfo.self, from: data)
            videos.append(video)
            url = ""
        } catch {
            print(error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
