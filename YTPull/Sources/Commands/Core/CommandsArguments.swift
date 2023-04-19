//
//  CommandsArguments.swift
//  YTPull
//
//  Created by Huy Nguyen on 19/04/2023.
//

import Foundation

extension Commands {
    /// Arguments object to build for `process.arguments` with some initialize support
    struct Arguments {
        let raw: [String]

        init(_ value: String) {
            self.init([value])
        }

        init(_ elements: [String]) {
            raw = elements
        }
    }
}

// MARK: - String Delegate supported
extension Commands.Arguments: Swift.ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
}

extension Commands.Arguments: Swift.ExpressibleByStringInterpolation {
    public init(stringInterpolation: DefaultStringInterpolation) {
        self.init(stringInterpolation.description)
    }
}

extension Commands.Arguments: Swift.ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: String...) {
        self.init(elements)
    }
}
