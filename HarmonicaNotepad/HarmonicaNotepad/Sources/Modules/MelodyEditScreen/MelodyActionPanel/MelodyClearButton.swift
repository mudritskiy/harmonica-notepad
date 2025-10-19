//
//  MelodyClearButton.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 10.06.2025.
//

import SwiftUI

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
