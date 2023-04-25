//
//  CommandsPermission.swift
//  YTPull
//
//  Created by Huy Nguyen on 19/04/2023.
//

import Foundation

private let kRunYTDLPPermission = "kRunYTDLPPermission"

private let kPermissionAllowed: Commands.Result = .init(statusCode: 9)

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
            if !UserDefaults.standard.bool(forKey: kRunYTDLPPermission) {
                let result = Commands.Task.run(request, isWaitUntilExit: true)
                UserDefaults.standard.set(result.statusCode == 0, forKey: kRunYTDLPPermission)
            }
            return kPermissionAllowed
        }
    }
}
