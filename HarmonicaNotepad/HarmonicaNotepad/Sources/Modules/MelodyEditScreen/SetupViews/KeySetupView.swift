//
//  KeySetupView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 31.05.2025.
//

import SwiftUI
import MusicTheory

struct KeySetupView: View {
    @State private var selectedKey: Key
    private let onSelect: (Key) -> Void

    private let allKeys: [Key] = Key.keysWithSharps

    // MARK: - Grid layout configuration
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    // MARK: - Init
    init(key: Key, onSelect: @escaping (Key) -> Void) {
        self._selectedKey = State(initialValue: key)
        self.onSelect = onSelect
    }

    // MARK: Render
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Choose Key")
                        .font(FontToken.title3.value)
                        .foregroundStyle(Theme.colors.text.secondary.color)
                        .padding(.top, 8)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Array(allKeys.enumerated()), id: \.offset) { index, key in
                            Button {
                                selectedKey = key
                            } label: {
                                _cellContent(with: key)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Set Key")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Select") {
                        onSelect(selectedKey)
                    }
                }
            }
        }
    }

    private func _cellContent(with key: Key) -> some View {
        Text(key.description)
            .font(FontToken.title3.value)
            .fontWeight(selectedKey == key ? .bold : .regular)
            .foregroundStyle(Theme.colors.text.secondary.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                _cellContentBackground(with: key)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func _cellContentBackground(with key: Key) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                selectedKey == key
                ? Theme.colors.background.primaryTinted.color
                : Color.clear
            )
            .strokeBorder(
                Theme.colors.text.secondary.color,
                lineWidth: selectedKey == key ? 2 : 1
            )
    }
}
