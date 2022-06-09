//
//  Validator.swift
//  
//
//  Created by Robert Walker on 6/3/22.
//

import Foundation

struct Validator {
    static func isNotBlank(_ str: String) -> Bool {
        return !str
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: .newlines)
            .isEmpty
    }
    
    static func trimmedAndSanitized(_ str: String) -> String {
        return sanitized(str)
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: .newlines)
    }
    
    // MARK: - Private Methods
    
    private static func sanitized(_ str: String) -> String {
        var strCopy = str
        strCopy.unicodeScalars.removeAll(where: { s in
            !(CharacterSet.whitespaces.contains(s) ||
              CharacterSet.alphanumerics.contains(s))
        })
        return strCopy
    }
}
