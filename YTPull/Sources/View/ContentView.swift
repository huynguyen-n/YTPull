//
//  ContentView.swift
//  YTPull
//
//  Created by Huy Nguyen on 04/04/2023.
//

import SwiftUI

struct ContentView: View {

    var colors = ["Red", "Green", "Blue", "Tartan"]
    @State private var url = ""
    @State private var selectedColor = ""

    var body: some View {
        VStack {
            TextField("https://www.youtube.com", text: $url)
            Button("Get Video Info", action: didTapGetURL).disabled(!url.isValid)
        }
        .padding()
    }

    private func didSelectPicker() {
        print("hello")
    }

    private func didTapGetURL() {
        guard url.isValid else { return }
        do {
            let data = try Execute.shared.excute(["-f", "bv/ba", "-j", url])
            let videoInfo = try JSONDecoder().decode(VideoInfo.self, from: data)
            print(videoInfo)
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
