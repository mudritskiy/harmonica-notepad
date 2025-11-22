//
//  MelodyActionButton.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 10.06.2025.
//

import SwiftUI

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
