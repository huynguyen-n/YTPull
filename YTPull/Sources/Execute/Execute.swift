//
//  ExecuterYTDLP.swift
//  YTPull
//
//  Created by Huy Nguyen on 07/04/2023.
//

import Foundation

enum ExecuteResult: Int32 {
    case success, failure
}

class Execute {

    static let shared: Execute = Execute()

    /// Call once time before start execute the `yt-dlp`.
    init() {
        let process = Process()
        process.launchPath = "/bin/chmod"
        process.arguments = ["u+x", Bundle.main.YTDLPPath!]
        process.launch()
        process.waitUntilExit()
    }

    func excute(_ args: [String]) throws -> Data {
        let process = Process()
        process.launchPath = Bundle.main.YTDLPPath
        process.arguments = args
        let pipeStdOut = Pipe()
        let pipeStdErr = Pipe()
        process.standardOutput = pipeStdOut
        process.standardError = pipeStdErr
        process.launch()
        let data = pipeStdOut.fileHandleForReading.readDataToEndOfFile()
        #if DEBUG
        print("Executed data ---- \(data.prettyPrintedJSONString ?? "❓ EMPTY")")
        #endif

        guard !process.isRunning else {
            return data
        }

        let result = ExecuteResult(rawValue: process.terminationStatus)

        guard result == .success else {
            let data = pipeStdErr.fileHandleForReading.readDataToEndOfFile()
            throw ExecuteError.pipeStdError(data)
        }

        return data
    }
}
