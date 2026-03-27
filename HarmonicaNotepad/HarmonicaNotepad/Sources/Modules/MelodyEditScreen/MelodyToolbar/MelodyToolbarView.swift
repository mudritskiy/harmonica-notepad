//
//  MelodyToolbarView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.03.2026.
//

import SwiftUI

struct MelodyToolbarViewProps {
    let isPlaying: Bool
    let tempoTitle: String
    let keyTitle: String

    let onPlayTap: Action
    let onClearTap: Action
    let onTempoTap: Action
    let onKeyTap: Action
}

struct MelodyToolbarView: View {
    let props: MelodyToolbarViewProps

    var body: some View {
        VStack(
            alignment: .center,
            spacing: .zero
        ) {
            HStack(
                alignment: .bottom,
                spacing: .zero
            ) {
                ToolbarButtonPlayView(
                    isPlaying: props.isPlaying,
                    onTap: props.onPlayTap
                )
                Spacer()
                HStack(
                    alignment: .center,
                    spacing: 12
                ) {
                    MelodyToolbarButtonTempoView(
                        subtitle: props.tempoTitle,
                        onTap: props.onTempoTap
                    )
                    MelodyToolbarButtonKeyView(
                        subtitle: props.keyTitle,
                        onTap: props.onKeyTap
                    )
                }
                Spacer()
                ToolbarButtonView(
                    icon: Image(systemName: "eraser.line.dashed.fill"),
                    onTap: props.onClearTap
                )
            }
        }
    }
}
