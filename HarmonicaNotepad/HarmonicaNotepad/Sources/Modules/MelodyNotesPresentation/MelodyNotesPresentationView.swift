//
//  MelodyNotesPresentationView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 29.03.2026.
//

import MusicTheory
import SwiftUI

struct MelodyNotesPresentationViewProps: Equatable {
    let presenetionStyle: MelodyNotePresenetionStyle
    let melodyRows: [MelodyRow]
    let playerEventStream: AsyncStream<PlayerEvent>

    let rowHeight: CGFloat
    let itemWidth: CGFloat

    init(
        presenetionStyle: MelodyNotePresenetionStyle = .numbersPrimary,
        melodyRows: [MelodyRow],
        playerEventStream: AsyncStream<PlayerEvent>
    ) {
        self.presenetionStyle = presenetionStyle
        self.melodyRows = melodyRows
        self.playerEventStream = playerEventStream

        rowHeight = presenetionStyle.height
        itemWidth = presenetionStyle.width
    }

    static func == (lhs: MelodyNotesPresentationViewProps, rhs: MelodyNotesPresentationViewProps) -> Bool {
        lhs.melodyRows == rhs.melodyRows
    }
}

struct MelodyNotesPresentationView: View {
    let props: MelodyNotesPresentationViewProps
    let gridColumns: [GridItem]

    @State private var playingNoteIndex: Int?
    @Binding private var cursorIndex: Int?

    init(props: MelodyNotesPresentationViewProps, cursorIndex: Binding<Int?>) {
        self.props = props
        self._cursorIndex = cursorIndex
        let size: GridItem.Size = .adaptive(minimum: props.itemWidth)
        gridColumns = [GridItem(size, spacing: 2)]
    }

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
                _rowContent(items: row.items, rowIndex: rowIndex)
                    .padding(4)
            }
            Spacer()
                .frame(height: props.rowHeight * 4)
        }
    }

    private func _rowContent(items: [MelodyRow.Item], rowIndex: Int) -> some View {
        LazyVGrid(
            columns: gridColumns,
            alignment: .leading,
            spacing: .zero
        ) {
            if items.isEmpty {
                _emptyRowContent(rowIndex: rowIndex)
            }
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                _notesCellContentView(item: item, isRowBeggining: index == 0)
            }
        }
    }

    private func _emptyRowContent(rowIndex: Int) -> some View {
        Spacer()
            .frame(height: props.rowHeight)
    }

    @ViewBuilder
    private func _notesCellContentView(item: MelodyRow.Item, isRowBeggining: Bool) -> some View {
        let leadingInset: CGFloat = isRowBeggining ? 4 : 0
        let isCursorVisible = _isCursorVisible(at: item.indexInMelody, isRowBeginning: isRowBeggining)

        if isCursorVisible {
            let alignment: Alignment = item.indexInMelody == cursorIndex ? .trailing : .leading
            ZStack(alignment: alignment) {
                _tappableNotePresentation(item: item, leadingInset: leadingInset)
                TextCursorView()
            }
        } else {
            _tappableNotePresentation(item: item, leadingInset: leadingInset)
        }
    }

    private func _tappableNotePresentation(item: MelodyRow.Item, leadingInset: CGFloat) -> some View {
        _notePresentation(item: item)
            .padding(.leading, leadingInset)
            .overlay {
                GeometryReader { geo in
                    HStack(spacing: 0) {
                        Color.clear
                            .frame(width: geo.size.width / 3)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                cursorIndex = item.indexInMelody - 1
                            }
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                cursorIndex = item.indexInMelody
                            }
                    }
                }
            }
    }

    private func _notePresentation(item: MelodyRow.Item) -> some View {
        MelodyNotePresenetionStyle.numbersPrimary
            .makeView(
                state: MelodyNotePresenetionState(
                    note: item.note.note,
                    type: item.note.type,
                    isPlaying: item.indexInMelody == playingNoteIndex
                )
            )
    }

    private func _isCursorVisible(at index: Int, isRowBeginning: Bool) -> Bool {
        guard let cursorIndex else { return false }
        
        let isCurrent = index == cursorIndex
        let isBeforeRowStart = isRowBeginning && cursorIndex == index - 1

        return isCurrent || isBeforeRowStart
    }
}
