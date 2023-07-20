//
//  Helpers.swift
//  YTPull
//
//  Created by Huy Nguyen on 07/07/2023.
//

import Foundation

extension Bundle {
    var YTDLPPath: String {
        guard let path = Bundle.main.path(forResource: "yt-dlp", ofType: "sh") else {
            fatalError("Can not found the \"yt-dlp.sh\" file!")
        }
        return path
    }
}

extension URL {
    func appending(filename: String) -> URL {
        appendingPathComponent(filename, isDirectory: false)
    }

    func appending(directory: String) -> URL {
        appendingPathComponent(directory, isDirectory: true)
    }

    static var temp: URL {
        let url = Files.temporaryDirectory
            .appending(directory: "com.github.huynguyen-n.YTPull")
        Files.createDirectoryIfNeeded(at: url)
        return url
    }

    static var logs: URL {
        let searchPath = FileManager.SearchPathDirectory.libraryDirectory
        var url = Files.urls(for: searchPath, in: .userDomainMask).first?
            .appending(directory: "Logs")
            .appending(directory: "com.github.huy.ytpull-store")  ?? URL(fileURLWithPath: "/dev/null")
        if !Files.createDirectoryIfNeeded(at: url) {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try? url.setResourceValues(resourceValues)
        }
        return url
    }
}

private extension URLComponents {
    var isYTURL: Bool {
        return scheme?.hasSuffix("youtube.com") != nil && path.hasSuffix("/watch")
    }
}

extension String {
    var buildYTURL: String? {
        var components = URLComponents(string: self)
        guard components?.isYTURL == true else {
            return nil
        }
        components?.queryItems?.removeAll(where: { $0.name != "v" })
        return components?.string
    }
}

