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

    init(tempo: Double, onSelect: @escaping (Tempo) -> Void) {
        self.selectedBpm = TempoStyle.tempo(for: Int(tempo))
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedBpm) {
                ForEach(TempoStyle.allCases, id:\.self) { style in
                    Text("\(style.presentation)").tag(style.rawValue)
                }
            }
            .pickerStyle(.wheel)
            .padding(.top, 8)
            Text("Tempo")
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
            Text(selectedBpm.valueRange)
                .font(.caption)
                .foregroundColor(.secondary)

            SwiftUI.Button(role: .none) {
                let tempo = Tempo(bpm: Double(selectedBpm.rawValue))
                onSelect(tempo)
            } label: {
                Text("Select")
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 4)
    }
}
