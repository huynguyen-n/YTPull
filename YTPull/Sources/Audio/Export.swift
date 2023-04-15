//
//  Export.swift
//  YTPull
//
//  Created by Huy Nguyen on 13/04/2023.
//

import Foundation
import AVFoundation
import Combine

enum ExportError: Error {
    case exportSessionStatus(AVAssetExportSession.Status)
}

class Export {

    private let directory = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "YTPull"
    private var composition: AVMutableComposition
    private var fileName: String

    private(set) var exportSession: AVAssetExportSession!

    init(composition: AVMutableComposition, fileName: String) {
        self.composition = composition
        self.fileName = fileName
    }

    func process(completion: @escaping (Bool, Error?) -> ()) {
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let outputYTPullUrl = downloadsDirectory.appendingPathComponent(directory)
        let outputUrl = outputYTPullUrl.appendingPathComponent("\(fileName).m4a")
        if FileManager.default.fileExists(atPath: outputUrl.path) {
            try? FileManager.default.removeItem(atPath: outputUrl.path)
        } else {
            try? FileManager.default.createDirectory(at: outputYTPullUrl, withIntermediateDirectories: true)
        }
        exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)!
        exportSession.outputFileType = AVFileType.m4a
        exportSession.outputURL = outputUrl
        exportSession.exportAsynchronously {
            switch self.exportSession.status {
            case .completed:
                completion(true, nil)
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                completion(false, nil)
            @unknown default:
                completion(false, nil)
            }
        }
    }
}
