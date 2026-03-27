//
//  TempoSetupView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 31.05.2025.
//

import SwiftUI
import MusicTheory

struct TempoSetupView: View {
    @State private var selectedBpm: TempoStyle
    private let onSelect: (Tempo) -> Void

    // MARK: - Init
    init(tempo: Double, onSelect: @escaping (Tempo) -> Void) {
        self._selectedBpm = State(initialValue: TempoStyle.tempo(for: Int(tempo)))
        self.onSelect = onSelect
    }

    // MARK: - Render
    var body: some View {
        NavigationStack {
            _contentView()
                .navigationTitle("Set Tempo")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Select") {
                            let tempo = Tempo(bpm: Double(selectedBpm.rawValue))
                            onSelect(tempo)
                        }
                    }
                }
        }
    }

    private func _contentView() -> some View {
        Form {
            Section {
                ForEach(TempoStyle.allCases, id: \.self) { style in
                    Button {
                        selectedBpm = style
                    } label: {
                        _tempoItem(with: style)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(
                        selectedBpm == style
                        ? Theme.colors.background.primaryTinted.color.opacity(0.5)
                        : Color.clear
                    )
                }
            } header: {
                Text("Available Tempos")
                    .font(FontToken.title3.value)
                    .foregroundStyle(Theme.colors.text.tertiary.color)
            }

            Section {
                _selectedItem()
            }
        }
    }

    private func _tempoItem(with style: TempoStyle) -> some View {
        HStack {
            Text(style.presentation)
                .font(FontToken.headline.value)
                .foregroundStyle(Theme.colors.text.primary.color)

            Spacer()

            Text("\(style.rawValue) bpm")
                .font(FontToken.headline.value)
                .foregroundStyle(Theme.colors.text.tertiary.color)
                .font(.body.monospacedDigit())
        }
        .contentShape(Rectangle())
    }

    private func _selectedItem() -> some View {
        HStack {
            Text("Selected Tempo")
                .font(FontToken.headline.value)
                .foregroundStyle(Theme.colors.text.primary.color)
            Spacer()
            Text("\(selectedBpm.presentation) — \(selectedBpm.rawValue) bpm")
                .font(FontToken.headline.value)
                .foregroundStyle(Theme.colors.text.tertiary.color)
        }    }
}
