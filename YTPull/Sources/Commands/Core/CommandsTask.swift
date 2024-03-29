//
//  CommandsTask.swift
//  YTPull
//
//  Created by Huy Nguyen on 19/04/2023.
//

import Foundation

extension Commands {
    /// Instance to execute a command with `Request` object
    enum Task {
        @discardableResult
        /// Main function to run command with `Request`
        /// - Parameter request: object to configure for process
        /// - Returns: `Result` object
        static func run(_ request: Request, isWaitUntilExit: Bool = false) -> Result {
            let process = request.process()

            let outputPipe = Pipe()
            process.standardOutput = outputPipe

            let errorPipe = Pipe()
            process.standardError = errorPipe

            do {
                try process.run()

                /// Need to call `waitUntilExit()` for system case like `chmod`, `yt-dlp` won't need.
                if isWaitUntilExit {
                    process.waitUntilExit()
                }

                let outputActual = try outputPipe.fileHandleForReading.readToEnd()
                let errorActual = try errorPipe.fileHandleForReading.readToEnd()

                guard !process.isRunning else {
                    /// Task is running, can't use `process.terminationStatus`
                    return Result(statusCode: .zero, data: errorActual)
                }
                if process.terminationStatus == EXIT_SUCCESS {
                    return Result(statusCode: process.terminationStatus, data: outputActual)
                }
                return Result(statusCode: process.terminationStatus, data: errorActual)
            } catch let error {
                return Result(statusCode: process.terminationStatus, error: error.localizedDescription)
            }
        }
    }
}
