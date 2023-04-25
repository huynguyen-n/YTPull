//
//  Responder.swift
//  YTPull
//
//  Created by Huy Nguyen on 20/04/2023.
//

import Foundation

enum ResponderStatus {
    case idle, loading, success, failure
}

struct Responder {
    var alertMessage = ""
    var status: ResponderStatus = .idle
}
