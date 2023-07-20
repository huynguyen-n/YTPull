//
//  Downloader.swift
//  YTPull
//
//  Created by Huy Nguyen on 19/04/2023.
//

import SwiftUI

enum DownloaderError: Error {
    case urlInvalid
}

final class Downloader: NSObject, ObservableObject {

    @Published var alertMessage = ""
    @Published var progress: CGFloat = 0.0

    private var video: VideoEntity!

    func start(_ video: VideoEntity) throws {
        self.video = video
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let request = URLRequest(url: URL(string: video.url)!)
        let sessionDownloadTask = session.downloadTask(with: request)
        sessionDownloadTask.resume()
    }
}

// MARK: - URLSessionDownloadDelegate
extension Downloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let file = File(name: video.title, mediaType: .video)
            try Files.copyItem(at: location, to: file.path)
            VideoStore.shared.update(storedURL: file.path.absoluteString, for: video)
        } catch {
            DispatchQueue.main.async {
                self.alertMessage = error.localizedDescription
            }
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        DispatchQueue.main.async { [weak self] in
            self?.progress = progress * 100
        }
    }
}
