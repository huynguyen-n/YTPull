//
//  DownloadConsoleErrorView.swift
//  YTPull
//
//  Created by Huy Nguyen on 17/07/2023.
//

import SwiftUI

struct DownloadConsoleErrorView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.badge.exclamationmark.fill").font(.system(size: 32))
            Text("Permissions need").font(.title)
            Text("Please move YTPull to your Applications and re-open.").font(.subheadline).foregroundStyle(.gray)
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Text("Quit")
            }
        }
        .padding()
    }
}

struct DownloadConsoleErrorView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadConsoleErrorView()
    }
}
