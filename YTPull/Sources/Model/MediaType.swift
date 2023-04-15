//
//  MediaType.swift
//  YTPull
//
//  Created by Huy Nguyen on 15/04/2023.
//

import Foundation

enum MediaType: CaseIterable {
    case audio
    case video
    case none

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
}
