//
//  Bundle.swift
//  YTPull
//
//  Created by Huy Nguyen on 07/04/2023.
//

import Foundation

extension Bundle {
    var YTDLPPath: String? {
        return Bundle.main.path(forResource: "yt-dlp", ofType: "sh")
    }
}
