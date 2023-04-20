//
//  FileManager.swift
//  YTPull
//
//  Created by Huy Nguyen on 20/04/2023.
//

import Foundation

struct File {
    enum FileError: Error {
        case notFoundYTPull
    }

    let name: String
    let mediaType: MediaType
    let ext: String

    init(name: String, mediaType: MediaType, ext: String = "") {
        self.name = name
        self.mediaType = mediaType
        self.ext = ext

        guard !isExist else { return }
        try? fileManager.createDirectory(at: application, withIntermediateDirectories: true)
    }

    private var fileManager: FileManager {
        FileManager.default
    }

    private var downloads: URL {
        fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
    }

    private var application: URL {
        downloads.appending(path: "YTPull")
    }

    var path: URL {
        var filePath = application.appending(path: name)
        if ext.isEmpty {
            filePath.appendPathExtension(for: mediaType.type)
        } else {
            filePath.appendPathExtension(ext)
        }
        return filePath
    }

    private var isExist: Bool {
        fileManager.fileExists(atPath: path.path())
    }
}
