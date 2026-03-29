//
//  MelodyNotesPresentationView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 29.03.2026.
//

import MusicTheory
import SwiftUI

struct MelodyNotesPresentationViewProps: Equatable {
    let melodyRows: [MelodyRow]
    let playerEventStream: AsyncStream<PlayerEvent>

    static func == (lhs: MelodyNotesPresentationViewProps, rhs: MelodyNotesPresentationViewProps) -> Bool {
        lhs.melodyRows == rhs.melodyRows
    }
}

struct MelodyNotesPresentationView: View {
    let props: MelodyNotesPresentationViewProps

    @State private var playingNoteIndex: Int?

    // MARK: - Render
    var body: some View {
        _contentView()
            .task {
                for await event in props.playerEventStream {
                    switch event {
                        case .play(let index):
                            playingNoteIndex = index
                        case .stop:
                            playingNoteIndex = nil
                    }
                }
            }
    }

    private func _contentView() -> some View {
        ScrollView(.vertical) {
            ForEach(Array(props.melodyRows.enumerated()), id: \.offset) { rowIndex, row in
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(30)), count: 10),
                    alignment: .leading,
                    spacing: 2
                ) {
                    if row.items.isEmpty {
                        Spacer()
                            .frame(width: 25, height: 25, alignment: .center)
                    }
                    ForEach(Array(row.items.enumerated()), id: \.offset) { index, item in
                        _notesCellContentView(item: item)
                    }
                }
                .padding(4)
            }
        }
    }

    @ViewBuilder
    private func _notesCellContentView(item: MelodyRow.Item) -> some View {
        let isPlaying: Bool = item.indexInMelody == playingNoteIndex
        switch item.note.type {
            case .silence:
                _spaceCell(isPlaying)
            default:
                MelodyNoteSimpleCellView(
                    note: item.note.note,
                    isPlaying: isPlaying
                )
        }
    }

    private func _spaceCell(_ isPlaying: Bool) -> some View {
        Spacer()
            .frame(width: 25, height: 25, alignment: .center)
            .background(
                MelodyNoteSimpleCellViewBackground(isActive: isPlaying)
            )
            .padding(2)
    }
}
