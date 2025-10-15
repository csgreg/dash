//
//  String.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import Foundation

/// Extensions for string validation
extension String {
    func isValidEmail() -> Bool {
        guard
            let regex = try? NSRegularExpression(
                pattern:
                "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                options: .caseInsensitive
            )
        else {
            return false
        }

        return regex.firstMatch(in: self, range: NSRange(location: 0, length: count)) != nil
    }

    func isValidPassword() -> Bool {
        return count >= 8
    }
}
