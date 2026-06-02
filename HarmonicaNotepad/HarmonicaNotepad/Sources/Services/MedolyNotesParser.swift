//
//  MedolyNotesParser.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 19.03.2026.
//

protocol MedolyNotesParser {
    func parseNotes(from text: String, baseNotes: [HarmonicaNote]) -> [MelodyNote]
}

struct MedolyNotesParserImpl: MedolyNotesParser {
    // MARK: - Public
    func parseNotes(from text: String, baseNotes: [HarmonicaNote]) -> [MelodyNote] {
        let normalizedText = _parseText(text)
        let notes = _parseNotes(from: normalizedText, baseNotes: baseNotes)
        return notes
    }

    // MARK: - Parse Text
    private func _parseText(_ text: String) -> [String] {
        let allowedSymbols = String.degree + String.apostrophe + String.minus + String.newLine
        let parsedText = text
            .replacingOccurrences(of: String.star, with: String.degree)
            .filter { char in
                char.isNumber || allowedSymbols.contains(char)
            }
            .replacedNewLinesWithOneNewLine()
            .minimizingWhitespaces()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let parseSegments = _parseSegments(parsedText)

        return parseSegments
    }

    private func _parseSegments(_ text: String) -> [String] {
        var result: [String] = []
        var current = ""
        var dashPending = false

        func commitCurrent() {
            if !current.isEmpty {
                if current.contains(where: { $0.isNumber }) {
                    result.append(current)
                }
                current = ""
            }
        }

        for char in text {
            if char == "\n" {
                commitCurrent()
                result.append(String(char))
                dashPending = false
            } else if char == "-" {
                commitCurrent()
                current = "-"
                dashPending = true
            } else if char.isNumber {
                if dashPending {
                    current.append(char)
                    dashPending = false
                } else {
                    commitCurrent()
                    current = String(char)
                }
            } else {
                current.append(char)
                dashPending = false
            }
        }

        commitCurrent()

        if let startIndex = result.firstIndex(where: { $0 != .newLine }),
           let endIndex = result.lastIndex(where: { $0 != .newLine }) {
            result = Array(result[startIndex...endIndex])
        } else {
            result = []
        }

        return result
    }

    // MARK: - Parse Notes
    private func _parseNotes(from items: [String], baseNotes: [HarmonicaNote]) -> [MelodyNote] {
        var result: [MelodyNote] = []
        items.forEach { item in
            if item == .newLine {
                result.append(.newLine)
            } else if let note = _parseNote(item, baseNotes: baseNotes) {
                result.append(note)
            }
        }
        return result
    }

    private func _parseNote(_ text: String, baseNotes: [HarmonicaNote]) -> MelodyNote? {
        var remaining = text

        let direction = _direction(from: &remaining)
        guard let hole = _hole(from: &remaining),
              let technique = _technique(from: remaining, direction: direction),
              let harmonicaNote = baseNotes.first(where: {
                  $0.hole == hole &&
                  $0.direction == direction &&
                  $0.technique == technique
              })
        else { return nil }

        return MelodyNote(type: .normal, note: harmonicaNote)
    }

    private func _direction(from text: inout String) -> BreathDirection {
        if text.hasPrefix(String.minus) {
            text = String(text.dropFirst())
            return .draw
        } else {
            return .blow
        }
    }

    private func _hole(from text: inout String) -> Int? {
        guard let firstChar = text.first, firstChar.isNumber,
              let hole = Int(String(firstChar))
        else { return nil }

        text = String(text.dropFirst())
        return hole
    }

    private func _technique(from text: String, direction: BreathDirection) -> NoteTechnique? {
        if text.hasPrefix(String.degree) {
            return direction == .blow ? .overblow : .overdraw
        }

        let apostrophes = min(text.prefix { $0 == "'" }.count, 3)

        guard apostrophes > 0 else {
            return .natural
        }

        return NoteTechnique.BendLevel(rawValue: apostrophes).map { .bend($0) }
    }
}
