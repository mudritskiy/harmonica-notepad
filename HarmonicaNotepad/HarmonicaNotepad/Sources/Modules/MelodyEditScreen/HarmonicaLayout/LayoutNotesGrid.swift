//
//  LayoutNotesGrid.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.06.2025.
//

struct LayoutNotesGrid {
    private let notes: [[HarmonicaNote?]]
    let holesRowIndex: Int
    var rowsCount: Int { notes.count}
    let holesRange: ClosedRange<Int> = 1...10
}

extension LayoutNotesGrid {
    subscript(row: Int, hole: Int) -> HarmonicaNote? {
        guard row >= 0, row < rowsCount, hole >= 0 else { return nil }
        let column = notes[row]
        guard hole <= column.count else { return nil }
        return notes[row][hole - 1]
    }

    init(with notes: [HarmonicaNote]) {
        let groupedNotes = Array(Dictionary(grouping: notes, by: \.hole).values)

        let maxBlowNotesPerHole = groupedNotes
            .map { $0.filter { $0.direction == .blow }.count }
            .max() ?? 1

        let maxDrawNotesPerHole = groupedNotes
            .map { $0.filter { $0.direction == .draw }.count }
            .max() ?? 1

        let holeRange = 1...10
        let columns = holeRange.count
        let rows = maxBlowNotesPerHole + 1 + maxDrawNotesPerHole

        var grid = Array(repeating: Array<HarmonicaNote?>(repeating: nil, count: columns), count: rows)

        for notes in groupedNotes {
            guard let hole = notes.first?.hole else { continue }
            let holeIndex = hole - 1
            let blowNotes = notes.filter { $0.direction == .blow }
            let drawNotes = notes.filter { $0.direction == .draw }

            let blowShift = maxBlowNotesPerHole - blowNotes.count
            for (i, note) in blowNotes.reversed().enumerated() {
                grid[blowShift + i][holeIndex] = note
            }

            let rowForHolesShift = 1
            let initialDraIndex = maxBlowNotesPerHole + rowForHolesShift
            for (i, note) in drawNotes.enumerated() {
                grid[initialDraIndex + i][holeIndex] = note
            }
        }

        self.init(notes: grid, holesRowIndex: maxBlowNotesPerHole + 1)
    }
}

extension HarmonicaLayout {
    func notes(by configuration: HarmonicaLayoutConfiguration) -> [HarmonicaNote] {
        let notes = self.notes.filter { note in
            if note.technique == .overdraw || note.technique == .overblow {
                return configuration.isOverbandsOn
            } else if case let .bend(level) = note.technique {
                guard level <= configuration.bendsLevel else { return false }
                if level > .none {
                    if !configuration.isBlowBendsOn, note.direction == .blow {
                        return false
                    }
                    if !configuration.isDrawBendsOn, note.direction == .draw {
                        return false
                    }
                }
                return level <= configuration.bendsLevel
            }
            return true
        }
        return notes
    }
}
