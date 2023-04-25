//
//  MediaType.swift
//  YTPull
//
//  Created by Huy Nguyen on 15/04/2023.
//

import AVFoundation
import Foundation

enum MediaType: CaseIterable {
    case audio
    case video
    case none // can not be select, use for hidden label

    var value: String {
        switch self {
        case .audio:
            return "Audio"
        case .video:
            return "Video"
        case .none:
            return ""
        }
    }

    var type: UTType {
        switch self {
        case .audio:
            return .mpeg4Audio
        case .video:
            return .mpeg4Movie
        case .none:
            return .png
        }
    }
}
