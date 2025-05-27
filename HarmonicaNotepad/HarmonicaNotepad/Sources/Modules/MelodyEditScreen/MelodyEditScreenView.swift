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
                MelodyPlayButton(isActive: viewModel.isPlayingMelody) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewModel.onPlayTap()
                    }
                }
                .animation(.bouncy, value: viewModel.isPlayingMelody)
                MelodyClearButton() {
                    viewModel.onClearTap()
                }
                SwiftUI.Button(role: .none) {
                    viewModel.onTempoTap()
                } label: {
                    Text("Tempo")
                }
                SwiftUI.Button(role: .none) {
                    viewModel.onKeyTap()
                } label: {
                    Text("Key")
                }
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

            if let layoutViewModel = viewModel.layoutViewModel {
                HarmonicaLayoutView(
                    viewModel: layoutViewModel
                )
            }
        }
    }
}

struct MelodyPlayButton: View {
    let isActive: Bool
    let onTap: () -> Void

    var iconName: String { isActive ? "stop.circle.fill" : "arrowtriangle.right.circle.fill" }
//    var title: String { isActive ? "Stop" : "Play" }

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
            .frame(width: 80)
            .padding(4)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.purple, lineWidth: 1)
            }
    }

    private func _contentView() -> some View {
        HStack(alignment: .center, spacing: 0) {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 24, height: 24)
                .symbolRenderingMode(.multicolor)
                .symbolEffect(.pulse, isActive: isActive)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            ZStack {
                if isActive {
                    _titleContent(with: "Stop")
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                } else {
                    _titleContent(with: "Play")
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        ))
                }
            }
            .clipped()
        }
    }

    private func _titleContent(with title: String) -> some View {
        Text(title)
            .font(.body)
            .foregroundStyle(.purple)
            .padding(.leading, 4)
            .stretching(.horizontal, alignment: .center)
    }
}

struct MelodyClearButton: View {
    let onTap: () -> Void

    var iconName: String { "xmark.circle.fill" }
    var title: String { "Clear" }

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
            .frame(width: 80)
            .padding(4)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.red.opacity(0.7), lineWidth: 1)
                    .foregroundStyle(.purple)
            }
    }

    private func _contentView() -> some View {
        HStack(alignment: .center, spacing: 0) {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 24, height: 24)
                .symbolRenderingMode(.multicolor)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.red, .red.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(title)
                .font(.body)
                .foregroundStyle(.red)
                .padding(.leading, 4)
                .stretching(.horizontal, alignment: .center)
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
