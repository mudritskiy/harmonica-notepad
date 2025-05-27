//
//  HarmonicaLayoutView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.05.2025.
//

import SwiftUI
import MusicTheory

final class HarmonicaLayoutViewModel: ObservableObject {
    @Published var notesGrid: LayoutNotesGrid

    let onNoteTap: (HarmonicaNote) -> Void
    let onSilenceTap: () -> Void
    let onNewLineTap: () -> Void

    private let player = MidiNotePlayer()
    private var playbackTask: Task<Void, Never>?

    init(
        layout: HarmonicaLayout = HarmonicaLayout(key: Key(type: .c)),
        onNoteTap: @escaping (HarmonicaNote) -> Void,
        onSilenceTap: @escaping () -> Void,
        onNewLineTap: @escaping () -> Void
    ) {
        self.notesGrid = LayoutNotesGrid(with: layout)
        self.onNoteTap = onNoteTap
        self.onSilenceTap = onSilenceTap
        self.onNewLineTap = onNewLineTap
    }

    func updateNoteGrid(with layout: HarmonicaLayout) {
        notesGrid = LayoutNotesGrid(with: layout)
    }
}

struct HarmonicaLayoutView: View {
    @ObservedObject var viewModel: HarmonicaLayoutViewModel

    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
                .stretching(.vertical)
            HStack(alignment: .center, spacing: .zero) {
                MelodyActionButton(iconName: "space") {
                    viewModel.onSilenceTap()
                }
                MelodyActionButton(iconName: "return") {
                    viewModel.onNewLineTap()
                }
                .padding(.leading, 8)
                MelodyActionButton(iconName: "delete.backward.fill") {
//                    viewModel.onSilenceTap()
                }
                .padding(.leading, 8)
//                SwiftUI.Button(role: .none) {
//                    viewModel.onSilenceTap()
//                } label: {
//                    Text("Silence")
//                }
            }
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(1...viewModel.notesGrid.rowsCount, id: \.self) { row in
                    GridRow {
                        ForEach(viewModel.notesGrid.holesRange, id: \.self) { hole in
                            _cellContent(row: row, hole: hole)
                        }
                    }
                }
            }
            .background(Color.gray.opacity(0.2))
            Spacer()
                .stretching(.vertical)
        }
    }

    @ViewBuilder
    private func _cellContent(row: Int, hole: Int) -> some View {
        if let note = viewModel.notesGrid[(row - 1), hole] {
            HoleCell(note: note) {
                viewModel.onNoteTap(note)
            }
        } else if row == viewModel.notesGrid.holesRowIndex {
            Text("\(hole)")
                .frame(minWidth: 30, maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .background(Color.gray.opacity(0.2))
        } else {
            Spacer()
                .aspectRatio(1, contentMode: .fill)
        }
    }
}

struct MelodyActionButton: View {
    let iconName: String
    let onTap: () -> Void

    var body: some View {
        SwiftUI.Button(role: .none) {
            onTap()
        } label: {
            _buttonContentView()
        }
        .buttonStyle(.plain)
    }

    private func _buttonContentView() -> some View {
        _contentView()
//            .frame(width: 80)
            .padding(8)
            .aspectRatio(1, contentMode: .fit)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.purple.opacity(0.7), lineWidth: 1)
                    .foregroundStyle(.purple)
            }
    }

    private func _contentView() -> some View {
        Image(systemName: iconName)
            .resizable()
            .scaledToFit()
            .frame(width: Constants.melodyActionButtonSize, height: Constants.melodyActionButtonSize)
//            .aspectRatio(1, contentMode: .fit)
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(
                LinearGradient(
                    colors: [.purple, .purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

enum Constants {
    static let melodyActionButtonSize: CGFloat = 24
}

struct HoleCell: View {
    let note: HarmonicaNote
    let color: Color
    let onTap: () -> Void

    init(note: HarmonicaNote, onTap: @escaping () -> Void) {
        self.note = note
        self.onTap = onTap
        color = switch note.technique {
            case .natural:
                switch note.direction {
                    case .blow: .red.opacity(0.7)
                    case .draw: .blue.opacity(0.7)
                }
            case .bend:
                switch note.direction {
                    case .blow: .red.opacity(0.5)
                    case .draw: .blue.opacity(0.5)
                }
            case .overblow, .overdraw: .red
        }
    }

    var body: some View {
        SwiftUI.Button(role: .none) {
            onTap()
        } label: {
            _cellContent()
        }
    }

    private func _cellContent() -> some View {
        let border = note.technique == .overblow || note.technique == .overdraw
        return Text(note.basePitch.key.description)
            .font(.caption)
            .foregroundColor(border ? color : .white)
            .frame(minWidth: 30, maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(border ? Color.clear : color)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(border ? color : Color.clear, lineWidth: 1)
            )
            .cornerRadius(6)
            .padding(.all, 2)
    }
}
