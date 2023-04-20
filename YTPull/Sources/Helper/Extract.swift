//
//  Extract.swift
//  YTPull
//
//  Created by Huy Nguyen on 13/04/2023.
//

import AVFoundation
import Foundation

enum ExtractError: Error {
    case urlInvalidation
    case audioAssetTrackError
    case audioCompositionTrackError
    case compositionInsertTimeRange
}

class ExtractImpl {
    private(set) var url: URL

    init(url: URL) {
        self.url = url
    }

    private func audioCompositionTrack(_ track: AVAssetTrack?) throws -> AVMutableComposition {
        guard let audioAssetTrack = track else {
            throw ExtractError.audioAssetTrackError
        }

        let composition = AVMutableComposition()

        guard let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            throw ExtractError.audioCompositionTrackError
        }

        do {
            try audioCompositionTrack.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: CMTime.zero)
        } catch {
            throw ExtractError.compositionInsertTimeRange
        }

        return composition
    }

    func process(_ completion: @escaping ((() throws -> AVMutableComposition) -> Void) ) {
        let asset = AVURLAsset(url: self.url)
        asset.loadTracks(withMediaType: .audio) { tracks, error in
            completion({ try self.audioCompositionTrack(tracks?.first) })
        }
    }
}
