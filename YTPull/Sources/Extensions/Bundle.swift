//
//  Bundle.swift
//  YTPull
//
//  Created by Huy Nguyen on 07/04/2023.
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
