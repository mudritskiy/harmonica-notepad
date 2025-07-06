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
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Text("Title")

            HStack(alignment: .center, spacing: 12) {
                SwiftUI.Button(role: .none) {
                    viewModel.onTempoTap()
                } label: {
                    Text("Tempo: \(Int(viewModel.tempo.bpm)) bpm")
                }
                SwiftUI.Button(role: .none) {
                    viewModel.onKeyTap()
                } label: {
                    Text("Key: \(viewModel.key.description)")
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
                TempoSetupView(tempo: viewModel.tempo.bpm) { tempo in
                    viewModel.onTempoChange(to: tempo)
                }
                    .presentationDetents([.fraction(0.4)])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(false)
                    .presentationBackgroundInteraction(.disabled)
                    .presentationContentInteraction(.resizes)
            }
            .sheet(isPresented: $viewModel.isPresentedKeySetup) {
                KeySetupView(key: viewModel.key) { key in
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
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Text("Cancel")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.onApplyTap()
                    dismiss()
                } label: {
                    Text("Apply")
                }
            }
        }
    }
}

