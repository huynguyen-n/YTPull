//
//  CommandsYTDLP.swift
//  YTPull
//
//  Created by Huy Nguyen on 19/04/2023.
//

import Foundation

extension Commands {
    /// Commands of `yt-dlp` supported for execute arguments/
    enum YTDLP: CommandsIO {
        case bestMedia

        private var command: String {
            switch self {
            case .bestMedia:
                return "b"
            }
        }

        /// Default request object for YTDLP
        /// `-f`: mean format want to execute
        /// `command`: default each case in YTDLP in future
        /// `-j`: get json value of execution
        var request: Commands.Request {
            Request(executableURL: Bundle.main.YTDLPPath, arguments: ["-f", command, "-j"])
        }

        func execute(for URL: String?) -> Result {
            var raw = request.arguments.raw
            raw.append(URL ?? "")
            let newRequest = Request(environment: request.environment, executableURL: request.executableURL, arguments: .init(raw))
            return Commands.Task.run(newRequest)
        }
    }
}
