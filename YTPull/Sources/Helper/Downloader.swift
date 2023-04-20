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
    @Published var isShowAlert = false
    @Published var progress: CGFloat = 0
    @Published private var video: VideoInfo!

    func start(_ video: VideoInfo) throws {
        self.video = video
        guard let url = video._url else {
            self.alertMessage = DownloaderError.urlInvalid.localizedDescription
            throw DownloaderError.urlInvalid
        }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        let request = URLRequest(url: url)
        let sessionDownloadTask = session.downloadTask(with: request)
        sessionDownloadTask.resume()
    }
}

// MARK: - URLSessionDownloadDelegate
extension Downloader: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let file = File(name: video.fulltitle, mediaType: .video)
            try FileManager.default.copyItem(at: location, to: file.path)
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
