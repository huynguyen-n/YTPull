//
//  MediaType.swift
//  YTPull
//
//  Created by Huy Nguyen on 15/04/2023.
//

import AVFoundation
import Foundation

enum MediaType: Int, CaseIterable {
    case none // can not be select, use for hidden label
    case audio
    case video


    var value: String {
        switch self {
        case .none:
            return "-"
        case .audio:
            return "Audio"
        case .video:
            return "Video"
        }
    }

    var type: UTType {
        switch self {
        case .none:
            return .png
        case .audio:
            return .mpeg4Audio
        case .video:
            return .mpeg4Movie
        }
    }

    init(_ type: Int16) {
        switch type {
        case 1:
            self = .audio
        case 2:
            self = .video
        default:
            self = .none
        }
    }
}
