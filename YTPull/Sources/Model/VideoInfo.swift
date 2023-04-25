//
//  VideoInfo.swift
//  YTPull
//
//  Created by Huy Nguyen on 07/04/2023.
//

import Foundation

struct VideoInfo: Hashable, Codable, Identifiable {
    var id: String
    var fulltitle: String
    var channel: String
    var url: String
    var _url: URL? {
        URL(string: url)
    }
    var thumbnail: String
}
