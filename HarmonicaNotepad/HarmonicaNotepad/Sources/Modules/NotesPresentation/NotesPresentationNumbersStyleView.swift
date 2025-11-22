//
//  NotesPresentationNumbersStyleViewModel.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 05.07.2025.
//

import SwiftUI

@Observable
final class NotesPresentationNumbersStyleViewModel {
    let notes: [MelodyNote]
    let notesRows: [[MelodyNote]]

    private let _melodyService = MelodyService()

    init(notes: [MelodyNote]) {
        self.notes = notes
        notesRows = _melodyService.breakInRows(notes: notes)
    }
}

struct NotesPresentationNumbersStyleView: View {
    @Bindable var viewModel: NotesPresentationNumbersStyleViewModel

    var body: some View {
        LazyHStack(alignment: .top, spacing: 0) {
            ForEach(Array(viewModel.notesRows.enumerated()), id: \.offset) { rowIndex, notes in
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(30)), count: 9),
                    alignment: .leading,
                    spacing: 8
                ) {
                    ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                        let isPlaying = false //viewModel.isPlayingNote(rowIndex: rowIndex, at: index)
                        if case .silence = note.type {
                            Spacer()
                                .frame(width: 25, height: 25, alignment: .center)
                                .background(
                                    MelodyNoteSimpleCellViewBackground(isActive: isPlaying)
                                )
                                .padding(2)
                        } else {
                            MelodyNoteSimpleCellView(
                                note: note.note,
                                isPlaying: isPlaying
                            )
                        }
                    }
                }
                .padding(4)
            }
        }
    }
}

#Preview {
    let preview = Preview()
    let notes = preview.sampleMelodyNotes()
    NotesPresentationNumbersStyleView(
        viewModel: NotesPresentationNumbersStyleViewModel(
            notes: notes
        )
    )
}

