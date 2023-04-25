//
//  MediaFormat.swift
//  YTPull
//
//  Created by Huy Nguyen on 12/04/2023.
//

import Foundation

struct MediaFormat: Hashable, Codable, Identifiable {
    private var format_id: String
    var id: String {
        format_id
    }
    var url: String
    var ext: String
}

extension MediaFormat {
    static func dummy() -> [MediaFormat] {
        [
            .init(format_id: "sb0", url: "", ext: "mhtml"),
            .init(format_id: "139", url: "", ext: "m4a")
        ]
    }
}
