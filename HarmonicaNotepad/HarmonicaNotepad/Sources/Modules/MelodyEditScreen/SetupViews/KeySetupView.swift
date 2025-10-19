//
//  KeySetupView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 31.05.2025.
//

import SwiftUI
import MusicTheory

struct KeySetupView: View {
    @State private var selectedKey: Int
    private let onSelect: (Key) -> Void
    private let allKeys = Key.allKeys

    init(key: Key, onSelect: @escaping (Key) -> Void) {
        self.selectedKey = allKeys.firstIndex(of: key) ?? 0
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedKey) {
                ForEach(Array(allKeys.enumerated()), id:\.offset) { index, key in
                    Text("\(key.description)").tag(index)
                }
            }
            .pickerStyle(.wheel)
            .padding(.top, 8)
            Text("Key")
                .font(.title2)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)

            SwiftUI.Button(role: .none) {
                onSelect(allKeys[selectedKey])
            } label: {
                Text("Select")
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 4)
    }
}
