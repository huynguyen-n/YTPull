//
//  Extracter.swift
//  YTPull
//
//  Created by Huy Nguyen on 20/04/2023.
//

import AVFoundation
import Combine
import SwiftUI

enum ExtractError: Error {
    case urlInvalid
    case audioAssetTrackError
    case audioCompositionTrackError
    case compositionInsertTimeRange
    case loadTracks(Error?)
    case unknownError
}

final class Extracter: ObservableObject {

    @Published private(set) var progress: CGFloat = 0

    private var responder: Responder = Responder()
    private var cancellabel: AnyCancellable?
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    func process(with video: VideoEntity) -> Future<Responder, ExtractError> {
        return Future { [weak self] promise in
            self?.cancellabel = self?.composition(URL(string: video.url))
                .subscribe(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    guard case .failure(let error) = completion else {
                        return
                    }
                    self.responder.alertMessage = error.localizedDescription
                    promise(.success(self.responder))
                } receiveValue: { [weak self] composition in
                    guard let self else { return }
                    let file = File(name: video.title, mediaType: .audio, ext: "m4a")
                    guard let assetExportSession = self.assetExportSession(composition, file: file) else {
                        return promise(.failure(.unknownError))
                    }
                    self.startTimer(assetExportSession)
                    assetExportSession.exportAsynchronously {
                        guard assetExportSession.status == .completed else {
                            self.timer.upstream.connect().cancel()
                            return promise(.failure(.unknownError))
                        }
                        self.responder.status = .success
                        VideoStore.shared.update(storedURL: file.path.absoluteString, for: video)
                    }
                }
        }
    }

    private func assetExportSession(_ composition: AVMutableComposition, file: File) -> AVAssetExportSession? {
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)
        exportSession?.outputFileType = AVFileType.m4a
        exportSession?.outputURL = file.path
        return exportSession
    }

    private func startTimer(_ exportSession: AVAssetExportSession) {
        var cancellable: AnyCancellable?
        cancellable = timer
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                let percentage = CGFloat(exportSession.progress * 100)
                DispatchQueue.main.async {
                    self.progress = percentage
                }
                if exportSession.progress == 1 {
                    cancellable?.cancel()
                    self.timer.upstream.connect().cancel()
                }
            }
    }

    private func composition(_ URL: URL?) -> Future<AVMutableComposition, ExtractError> {
        return Future { promise in
            guard let URL = URL else {
                return promise(.failure(.urlInvalid))
            }
            let asset = AVURLAsset(url: URL)
            asset.loadTracks(withMediaType: .audio) { tracks, error in
                guard let tracks = tracks, let audioAssetTrack = tracks.first  else {
                    return promise(.failure(.loadTracks(error)))
                }
                let composition = AVMutableComposition()
                guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
                    return promise(.failure(.audioCompositionTrackError))
                }
                do {
                    try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
                } catch {
                    promise(.failure(.compositionInsertTimeRange))
                }
                promise(.success(composition))
            }
        }
    }

    deinit {
        cancellabel?.cancel()
    }
}
