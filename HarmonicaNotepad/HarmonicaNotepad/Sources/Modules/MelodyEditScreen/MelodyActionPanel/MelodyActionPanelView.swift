//
//  MelodyActionPanelView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 10.06.2025.
//

import Combine
import SwiftUI

final class MelodyActionPanelViewModel: ObservableObject {
    @Published var isPlayingMelody: Bool = false
    var isPlayingCancellable: AnyCancellable?

    let onSilenceTap: () -> Void
    let onNewLineTap: () -> Void
    let onDeleteTap: () -> Void

    let onPlayTap: () -> Void
    let onClearTap: () -> Void

    init(
        playerService: PlayerServiceState,
        onSilenceTap: @escaping () -> Void,
        onNewLineTap: @escaping () -> Void,
        onDeleteTap: @escaping () -> Void,
        onPlayTap: @escaping () -> Void,
        onClearTap: @escaping () -> Void
    ) {
        self.onSilenceTap = onSilenceTap
        self.onNewLineTap = onNewLineTap
        self.onDeleteTap = onDeleteTap
        self.onPlayTap = onPlayTap
        self.onClearTap = onClearTap

        isPlayingCancellable = playerService.isPlayingMelodyPublisher
            .sink { [weak self] isPlayingMelody in
                withAnimation(.easeInOut(duration: 0.4)) {
                    self?.isPlayingMelody = isPlayingMelody
                }
            }
    }
}

struct MelodyActionPanelView: View {
    @ObservedObject var viewModel: MelodyActionPanelViewModel

    var body: some View {
        HStack(alignment: .center, spacing: .zero) {
            MelodyPlayButton(isActive: viewModel.isPlayingMelody) {
                viewModel.onPlayTap()
            }
            Spacer()
            MelodyActionButton(iconName: "space") {
                viewModel.onSilenceTap()
            }
            MelodyActionButton(iconName: "return") {
                viewModel.onNewLineTap()
            }
            .padding(.leading, 8)
            MelodyActionButton(iconName: "delete.backward.fill") {
                viewModel.onDeleteTap()
            }
            .padding(.leading, 8)
            Spacer()
            MelodyClearButton() {
                viewModel.onClearTap()
            }
        }
    }
}

#Preview {
    MelodyActionPanelView(
        viewModel: MelodyActionPanelViewModel(
            playerService: PlayerService(),
            onSilenceTap: {},
            onNewLineTap: {},
            onDeleteTap: {},
            onPlayTap: {},
            onClearTap: {}
        )
    )
}
