//
//  String.swift
//  YTPull
//
//  Created by Huy Nguyen on 07/04/2023.
//

import Foundation

extension String {
    var isValid: Bool {
        let pattern = "((https|http)://){0,1}((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.numberOfMatches(in: self, range: NSMakeRange(.zero, self.utf16.count))
            return matches == 1
        } catch {
            return false
        }
    }
}
