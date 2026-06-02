//
//  SongBottomToolbar.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.03.2026.
//

import SwiftUI

struct SongBottomToolbarView: View {
    let isPlaying: Bool
    let onPlayTap: Action
    let onEditTap: Action

    var body: some View {
        VStack(
            alignment: .center,
            spacing: .zero
        ) {
            HStack(
                alignment: .center,
                spacing: .zero
            ) {
                ToolbarButtonPlayView(
                    isPlaying: isPlaying,
                    onTap: onPlayTap
                )
                Spacer()
                ToolbarButtonView(
                    icon: Image(systemName: "music.quarternote.3"),
                    onTap: onEditTap
                )
            }
        }
    }
}
