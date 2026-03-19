//
//  MelodyService.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 23.11.2025.
//

import MusicTheory

protocol MelodyService {
    func breakInRows(notes: [MelodyNote]) -> [[MelodyNote]]
    func parseNotes(from text: String, baseNotes: [HarmonicaNote]) -> [MelodyNote]
}

struct MelodyServiceImpl: MelodyService {
    let medolyNotesParser: MedolyNotesParser

    init(
        medolyNotesParser: MedolyNotesParser = MedolyNotesParserImpl()
    ) {
        self.medolyNotesParser = medolyNotesParser
    }

    func breakInRows(notes: [MelodyNote]) -> [[MelodyNote]] {
        var result: [[MelodyNote]] = [notes]
        while let lastRow = result.last,
              let splitIndex = lastRow.firstIndex(where: { $0.type == .newLine }) {
            let firstPart = Array(lastRow[..<splitIndex])
            let secondPart = Array(lastRow[(splitIndex+1)...])
            result.removeLast()
            result.append(contentsOf: [firstPart, secondPart])
        }
        return result
    }

    func parseNotes(from text: String, baseNotes: [HarmonicaNote]) -> [MelodyNote] {
        medolyNotesParser.parseNotes(from: text, baseNotes: baseNotes)
    }
}
