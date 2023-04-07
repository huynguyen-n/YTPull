//
//  ExecuteYTDLPError.swift
//  YTPull
//
//  Created by Huy Nguyen on 07/04/2023.
//

import Foundation

enum ExecuteError: Error {
    case pipeStdError(Data)
}
