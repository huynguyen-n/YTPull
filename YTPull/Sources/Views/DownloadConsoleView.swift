//
//  ContentView.swift
//  YTPull
//
//  Created by Huy Nguyen on 04/04/2023.
//

import SwiftUI
import AVFoundation
import Combine

struct DownloadConsoleView: View {
    @ObservedObject var viewModel: DownloadInputViewModel

    var body: some View {
        VStack {
            DownloadInputView(viewModel: viewModel)
            DownloadListView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadConsoleView(viewModel: .init())
    }
}
