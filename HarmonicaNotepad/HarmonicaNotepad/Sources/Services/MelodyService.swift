//
//  MelodyService.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 23.11.2025.
//

import MusicTheory

struct MelodyRow: Equatable {
    struct Item: Equatable {
        let note: MelodyNote
        let indexInMelody: Int
    }

    let items: [Item]
}

protocol MelodyService {
    func breakInRows(notes: [MelodyNote]) -> [[MelodyNote]]
    func breakInRows(notes: [MelodyNote]) -> [MelodyRow]
    func parseNotes(from text: String, baseNotes: [HarmonicaNote]) -> [MelodyNote]
}

struct MelodyServiceImpl: MelodyService {
    let medolyNotesParser: MedolyNotesParser

    init(
        medolyNotesParser: MedolyNotesParser = MedolyNotesParserImpl()
    ) {
        self.medolyNotesParser = medolyNotesParser
    }

    #warning("remove old way to break melody on notes")
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

    func breakInRows(notes: [MelodyNote]) -> [MelodyRow] {
        var result: [MelodyRow] = []
        var currentRow: [MelodyRow.Item] = []

        for (index, note) in notes.enumerated() {
            if note.type == .newLine {
                result.append(MelodyRow(items: currentRow))
                currentRow.removeAll()
                continue
            }

            currentRow.append(
                MelodyRow.Item(
                    note: note,
                    indexInMelody: index
                )
            )
        }

        if !currentRow.isEmpty {
            result.append(MelodyRow(items: currentRow))
        }

        return result
    }

    func parseNotes(from text: String, baseNotes: [HarmonicaNote]) -> [MelodyNote] {
        medolyNotesParser.parseNotes(from: text, baseNotes: baseNotes)
    }
}
