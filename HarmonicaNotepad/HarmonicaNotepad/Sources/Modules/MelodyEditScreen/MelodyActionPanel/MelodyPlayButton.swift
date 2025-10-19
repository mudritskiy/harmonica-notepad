//
//  MelodyPlayButton.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 10.06.2025.
//

import SwiftUI

struct MelodyPlayButton: View {
    let isActive: Bool
    let onTap: () -> Void

    var iconName: String { isActive ? "stop.circle.fill" : "arrowtriangle.right.circle.fill" }

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
