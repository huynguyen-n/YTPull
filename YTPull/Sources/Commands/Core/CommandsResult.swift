//
//  CommandsResult.swift
//  YTPull
//
//  Created by Huy Nguyen on 19/04/2023.
//

import Foundation

extension Commands {
    /// Result from commands executable.
    struct Result {
        /// get status code after execute
        let statusCode: Int32
        /// get `Data` output
        let data: Data?

        /// get error localization
        let error: String?

        /// get `String` output
        var output: String {
            var result = ""
            if let outputData = data {
                result = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            }
            return result
        }

        init(statusCode: Int32, data: Data? = nil, error: String? = nil) {
            self.statusCode = statusCode
            self.data = data
            self.error = error
        }
    }
}
