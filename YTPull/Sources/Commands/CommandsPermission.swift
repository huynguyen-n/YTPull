//
//  CommandsPermission.swift
//  YTPull
//
//  Created by Huy Nguyen on 19/04/2023.
//

import Foundation

extension Commands {
    /// Permissiong for specific file case
    enum Permission: CommandsIO {
        case ytdlp

        private var fileURL: String {
            switch self {
            case .ytdlp:
                return Bundle.main.YTDLPPath
            }
        }

        var request: Commands.Request {
            Request(executableURL: "/bin/chmod", arguments: ["u+x", fileURL])
        }

        @discardableResult
        func execute(for URL: String? = nil) -> Commands.Result {
            return Commands.Task.run(request, isWaitUntilExit: true)
        }
    }
}
