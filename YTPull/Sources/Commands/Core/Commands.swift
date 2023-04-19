//
//  Commands.swift
//  YTPull
//
//  Created by Huy Nguyen on 18/04/2023.
//

import Foundation

/// Default instance to execute from all the app
enum Commands { /* Do Nothing */ }

/// Minimum requirement of any enum to call the `Command.Task`.
protocol CommandsIO {
    /// Request object needed to call a execute
    var request: Commands.Request { get }

    @discardableResult
    /// Execute function in case `YTDLP` will need a parameter media URL
    /// - Parameter URL: optional `YTDLP` will need
    /// - Returns: object about the result executed
    func execute(for URL: String?) -> Commands.Result
}
