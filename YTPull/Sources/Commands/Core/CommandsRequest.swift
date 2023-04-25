//
//  CommandsRequest.swift
//  YTPull
//
//  Created by Huy Nguyen on 19/04/2023.
//

import Foundation

extension Commands {
    /// Instance needed to execute any command
    struct Request {
        var environment: [String: String]?
        var executableURL: String
        var arguments: Arguments

        /// Create `Process` object instance needed to execute any command
        /// - Returns: `Process` object to use for `try process.run()`
        func process() -> Process {
            let process = Process()
            if process.isRunning {
                process.terminate()
            }
            process.executableURL = URL(fileURLWithPath: executableURL)
            if let environment = environment {
                process.environment = environment
            }
            process.arguments = arguments.raw
            return process
        }
    }
}
