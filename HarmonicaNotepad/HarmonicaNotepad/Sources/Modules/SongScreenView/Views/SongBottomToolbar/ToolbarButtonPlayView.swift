//
//  SongBottomToolbarButtonPlayView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.03.2026.
//

import SwiftUI

struct ToolbarButtonPlayView: View {
    // MARK: - State
    @State private var isAnimating: Bool = false

    // MARK: - Properties
    let isPlaying: Bool
    let onTap: Action
    private let _animationDuration: TimeInterval = 0.75

    // MARK: - Render
    var body: some View {
        _button()
            .task(id: isPlaying) {
                guard isPlaying else {
                    isAnimating = false
                    return
                }
                await _animationHadlning()
            }
    }

    private func _button() -> some View {
        Button(action: onTap) {
            _iconPlay()
        }
        .buttonStyle(.plain)
    }

    private func _iconPlay() -> some View {
        _iconPlayContant()
            .id(isPlaying)
            .transition(
                .scale(scale: 0.6)
                .combined(with: .opacity)
            )
            .animation(.linear, value: isAnimating)
            .animation(.linear, value: isPlaying)
    }

    private func _iconPlayContant() -> some View {
        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            .resizable()
            .frame(width: 28, height: 28)
            .scaleEffect(isAnimating ? 0.9 : 1)
            .offset(x: isPlaying ? 1 : 4)
            .foregroundStyle(Theme.colors.background.secondary.color)
            .padding(.all, 16)
            .background {
                ButtonBackgroundView()
            }
    }

    // MARK: - Animation
    private func _animationHadlning() async {
        try? await Task.sleep(for: .milliseconds(50))

        guard !Task.isCancelled else { return }

        while !Task.isCancelled {
            withAnimation(.easeInOut(duration: _animationDuration)) {
                isAnimating = true
            }
            try? await Task.sleep(for: .seconds(_animationDuration))
            guard !Task.isCancelled else { break }
            withAnimation(.easeInOut(duration: _animationDuration)) {
                isAnimating = false
            }
            try? await Task.sleep(for: .seconds(_animationDuration))
        }
    }
}
