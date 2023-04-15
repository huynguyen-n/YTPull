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

extension VideoInfo {
    static func dummy() -> VideoInfo {
        .init(
            id: "tPEE9ZwTmy0",
            fulltitle: "Shortest Video on Youtube",
            channel: "Mylo the Cat",
            url: "",
            thumbnail: "https://i.ytimg.com/vi/tPEE9ZwTmy0/sddefault.jpg?sqp=-oaymwEmCIAFEOAD8quKqQMa8AEB-AHUBoAC1gOKAgwIABABGHIgZig2MA8=&rs=AOn4CLDJz0eNEQx0dF1GRMnw4KYcuonwdA")
    }
}
