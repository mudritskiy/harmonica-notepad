//
//  MelodyEditScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.05.2025.
//

import SwiftUI

struct MelodyEditScreenView: View {
    @ObservedObject var viewModel: MelodyEditScreenViewModel
    @State private var isAnimating = false

    var body: some View {
        VStack {
            Text("Title")

            HStack(alignment: .center, spacing: 12) {
                SwiftUI.Button(role: .none) {
                    viewModel.onTempoTap()
                } label: {
                    Text("Tempo: \(Int(viewModel.melody.tempo.bpm)) bpm")
                }
                SwiftUI.Button(role: .none) {
                    viewModel.onKeyTap()
                } label: {
                    Text("Key: \(viewModel.melody.key.description)")
                }
                .padding(.leading, 12)
            }

            ScrollView(.vertical) {
                ForEach(Array(viewModel.melodyRows.enumerated()), id: \.offset) { rowIndex, notes in
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(30)), count: 10),
                        alignment: .leading,
                        spacing: 2
                    ) {
                        ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                            let isPlaying = viewModel.isPlayingNote(rowIndex: rowIndex, at: index)
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
            .stretching(.vertical)
            .sheet(isPresented: $viewModel.isPresentedTempoSetup) {
                TempoSetupView(tempo: viewModel.melody.tempo.bpm) { tempo in
                    viewModel.onTempoChange(to: tempo)
                }
                    .presentationDetents([.fraction(0.4)])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(false)
                    .presentationBackgroundInteraction(.disabled)
                    .presentationContentInteraction(.resizes)
            }
            .sheet(isPresented: $viewModel.isPresentedKeySetup) {
                KeySetupView(key: viewModel.melody.key) { key in
                    viewModel.onKeyChange(to: key)
                }
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(false)
                .presentationBackgroundInteraction(.disabled)
                .presentationContentInteraction(.resizes)
            }

            MelodyActionPanelView(viewModel: viewModel.melodyActionPanelViewModel)

            HarmonicaLayoutView(viewModel: viewModel.layoutViewModel)
        }
    }
}

struct MelodyNoteSimpleCellView: View {
    let note: HarmonicaNote
    let isPlaying: Bool

    var body: some View {
        Text(note.description)
            .font(.system(size: 11))
            .cornerRadius(4)
            .padding(2)
            .frame(width: 25, height: 25, alignment: .center)
            .background(
                MelodyNoteSimpleCellViewBackground(isActive: isPlaying)
            )
            .aspectRatio(1, contentMode: .fit)
    }
}

struct MelodyNoteSimpleCellViewBackground: View {
    let isActive: Bool
    var body: some View {
        if isActive {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
        } else {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        }

    }
}
