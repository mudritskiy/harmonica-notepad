//
//  MelodyEditScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.05.2025.
//

import SwiftUI

struct MelodyEditScreenView: View {
    @ObservedObject var viewModel: MelodyEditScreenViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        _contentView()
            .toolbarVisibility(.hidden, for: .tabBar)
            .toolbar {
                _toolbarContentView()
            }
            .navigationBarBackButtonHidden()
            .onFirstAppear {
                viewModel.dismiss = { dismiss() }
            }
            .sheet(isPresented: $viewModel.isPresentedTempoSetup) {
                _tempoSetupView()
            }
            .sheet(isPresented: $viewModel.isPresentedKeySetup) {
                _keySetupView()
            }
            .alertInfo(isPresented: $viewModel.showAlert, viewModel.alertInfo)
    }

    private func _contentView() -> some View  {
        VStack {
            Text("Title")
            _headerContentView()
            _melodyContentView()
                .stretching(.vertical)
            MelodyActionPanelView(viewModel: viewModel.melodyActionPanelViewModel)
            HarmonicaLayoutView(viewModel: viewModel.layoutViewModel)
        }
    }

    private func _melodyContentView() -> some View {
        ScrollView(.vertical) {
            ForEach(Array(viewModel.melodyRows.enumerated()), id: \.offset) { rowIndex, notes in
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(30)), count: 10),
                    alignment: .leading,
                    spacing: 2
                ) {
                    ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                        _notesCellContentView(rowIndex: rowIndex, index: index, note: note)
                    }
                }
                .padding(4)
            }
        }
    }

    @ViewBuilder
    private func _notesCellContentView(rowIndex: Int, index: Int, note: MelodyNote) -> some View {
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

    private func _headerContentView() -> some View {
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
        }    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private func _toolbarContentView() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onCancelTap()
            } label: {
                Text("Cancel")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.onApplyTap()
            } label: {
                Text("Apply")
            }
        }
    }

    // MARK: - Bottomsheets
    private func _tempoSetupView() -> some View {
        TempoSetupView(tempo: viewModel.tempo.bpm) { tempo in
            viewModel.onTempoChange(to: tempo)
        }
        .presentationDetents([.fraction(0.4)])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(false)
        .presentationBackgroundInteraction(.disabled)
        .presentationContentInteraction(.resizes)
   }

    private func _keySetupView() -> some View {
        KeySetupView(key: viewModel.key) { key in
            viewModel.onKeyChange(to: key)
        }
        .presentationDetents([.fraction(0.3)])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(false)
        .presentationBackgroundInteraction(.disabled)
        .presentationContentInteraction(.resizes)
    }
}
