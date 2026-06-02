//
//  String+Formating.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 19.03.2026.
//

import Foundation

public extension String {
    func minimizingWhitespaces() -> String {
        guard !isEmpty else { return self }
        
        let pattern = "\\s{2,}"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return self }

        let range = NSRange(location: 0, length: utf16.count)
        let replacedString = regex.stringByReplacingMatches(
            in: self,
            options: [],
            range: range,
            withTemplate: " "
        )
        return replacedString
    }

    func trimmingNewLines() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func replacedNewLinesWithOneNewLine() -> String {
        guard !isEmpty else { return self }
        
        let pattern = "\\n{2,}"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return self }

        let range = NSRange(location: 0, length: utf16.count)
        let replacedString = regex.stringByReplacingMatches(
            in: self,
            options: [],
            range: range,
            withTemplate: "\n"
        )
        return replacedString
    }
}
