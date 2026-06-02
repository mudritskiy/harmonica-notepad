//
//  HarmonicaLayoutView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.05.2025.
//

import SwiftUI

struct HarmonicaLayoutView: View {
    let props: HarmonicaLayoutViewProps

    // MARK: - Render
    var body: some View {
        _keyboardContainerView()
    }

    private func _keyboardContainerView() -> some View {
        CardContainer(
            cornerRadius: 24,
            borderWidth: 1,
            backgroundColor: props.backgroundColor.color,
            borderColor: props.backgroundColor.color
        ) {
            ZStack(alignment: .bottomTrailing) {
                _keyboardView()
                    .frame(maxWidth: .infinity)
                ServiceKeyboardView(props: props.serviceKeyboardProps)
                    .padding(.horizontal, 2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .themeShadow()
    }

    private func _keyboardView() -> some View {
        VStack(spacing: .zero) {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(1...props.notesGrid.rowsCount, id: \.self) { row in
                    GridRow {
                        ForEach(props.notesGrid.holesRange, id: \.self) { hole in
                            _cellContent(row: row, hole: hole)
                                .transition(.asymmetric(
                                    insertion:
                                            .move(edge: row < props.notesGrid.holesRowIndex ? .bottom : .top)
                                            .combined(with: .opacity),
                                    removal:
                                            .move(edge: row < props.notesGrid.holesRowIndex ? .bottom : .top)
                                            .combined(with: .opacity)
                                )
)
                        }
                    }
                }
                if props.systemKeyboardRowsCount > 0 {
                    _serviceKeysFakeSpace()
                }
            }
        }
    }

    @ViewBuilder
    private func _cellContent(row: Int, hole: Int) -> some View {
        if let note = props.notesGrid[(row - 1), hole] {
            _noteView(with: note)
                .padding(2)
        } else if row == props.notesGrid.holesRowIndex {
            _holeView(with: hole)
                .padding(.vertical, 2)
        } else {
            Spacer()
        }
    }

    // MARK: - Note
    private func _noteView(with note: HarmonicaNote) -> some View {
        HoleCell(note: note, font: props.font, keySize: props.keySize) {
            props.onNoteTap(note)
        }
        .shadow(
            color: Theme.colors.background.shadow.color,
            radius: 1,
            x: 0,
            y: 0
        )
    }

    // MARK: - Hole
    private func _holeView(with hole: Int) -> some View {
        Text("\(hole)")
            .font(props.font.value)
            .foregroundStyle(props.fontColor.color)
            .frame(maxWidth: .infinity)
            .background(
                Theme.colors.background.accent.color
                    .clipShape(
                        RoundedCorner(
                            radius: 8,
                            corners: _corners(with: hole)
                        )
                    )
            )
    }

    private func _corners(with hole: Int) -> UIRectCorner {
        switch hole {
            case 1: [.topLeft, .bottomLeft]
            case 10: [.topRight, .bottomRight]
            default: []
        }
    }

    // MARK: - Service Keys Space
    private func _serviceKeysFakeSpace() -> some View {
        ForEach(1...props.systemKeyboardRowsCount, id: \.self) { row in
            GridRow {
                ForEach(props.notesGrid.holesRange, id: \.self) { hole in
                    _serviceKeyFakeSpaceItem()
                }
            }
        }
    }

    private func _serviceKeyFakeSpaceItem() -> some View {
        Color.clear
            .frame(
                width: props.keySize.width,
                height: props.keySize.height
            )
            .padding(2)
    }
}
