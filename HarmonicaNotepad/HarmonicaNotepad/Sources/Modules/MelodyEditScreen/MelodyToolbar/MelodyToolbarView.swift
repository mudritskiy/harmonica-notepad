//
//  MelodyToolbarView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.03.2026.
//

import SwiftUI

struct MelodyToolbarViewProps: Equatable {
    let playerEventStream: AsyncStream<PlayerEvent>

    let tempoTitle: String
    let keyTitle: String

    let onPlayTap: Action
    let onClearTap: Action
    let onTempoTap: Action
    let onKeyTap: Action

    static func == (lhs: MelodyToolbarViewProps, rhs: MelodyToolbarViewProps) -> Bool {
        lhs.tempoTitle == rhs.tempoTitle &&
        lhs.keyTitle == rhs.keyTitle
    }
}

struct MelodyToolbarView: View {
    let props: MelodyToolbarViewProps

    @State var isPlaying: Bool = false

    // MARK: - Render
    var body: some View {
        _content()
            .task {
                for await event in props.playerEventStream {
                    let isPlaying = {
                        if case .play = event { return true }
                        return false
                    }()

                    if self.isPlaying != isPlaying {
                        self.isPlaying = isPlaying
                    }
                }
            }
    }

    private func _content() -> some View {
        VStack(
            alignment: .center,
            spacing: .zero
        ) {
            HStack(
                alignment: .bottom,
                spacing: .zero
            ) {
                _playButton()
                Spacer()
                HStack(
                    alignment: .center,
                    spacing: 12
                ) {
                    _tempoButton()
                    _keyButton()
                }
                Spacer()
                _clearButton()
            }
        }
    }

    private func _playButton() -> some View {
        ToolbarButtonPlayView(
            isPlaying: isPlaying,
            onTap: props.onPlayTap
        )
    }

    private func _tempoButton() -> some View {
        MelodyToolbarButtonTempoView(
            subtitle: props.tempoTitle,
            onTap: props.onTempoTap
        )
    }

    private func _keyButton() -> some View {
        MelodyToolbarButtonKeyView(
            subtitle: props.keyTitle,
            onTap: props.onKeyTap
        )
    }

    private func _clearButton() -> some View {
        ToolbarButtonView(
            icon: Image(systemName: "eraser.line.dashed.fill"),
            onTap: props.onClearTap
        )
    }
}
