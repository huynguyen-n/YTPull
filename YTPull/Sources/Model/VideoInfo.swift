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

var mockYTURL: [String] = [
    "https://www.youtube.com/watch?v=RZAq-_gz_W8",
    "https://www.youtube.com/watch?v=eDcQDnh6Nfk",
    "https://www.youtube.com/watch?v=qXeORn7NVbU",
    "https://www.youtube.com/watch?v=FxYw0XPEoKE",
    "https://www.youtube.com/watch?v=EvuL5jyCHOw",
    "https://www.youtube.com/watch?v=0T-rnoSJsKI",
    "https://www.youtube.com/watch?v=pIGZq79hoSI",
    "https://www.youtube.com/watch?v=aYGS6uEJv7c",
    "https://www.youtube.com/watch?v=xoCOXlShLz8",
    "https://www.youtube.com/watch?v=qtdonhjZDCI",
]
