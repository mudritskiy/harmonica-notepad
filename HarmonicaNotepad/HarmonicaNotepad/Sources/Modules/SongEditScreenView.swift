//
//  SongEditScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 22.06.2025.
//

import SwiftUI

@Observable
final class SongEditScreenViewModel {
    enum Route: Hashable {
        case editMelody
    }

    @ObservationIgnored
    var song: HarmonicaSong = HarmonicaSong(title: "", melody: [])
    var title: String = ""
}

struct SongEditScreenView: View {
    @Bindable private var _viewModel: SongEditScreenViewModel
    @Environment(MainRouter.self) private var _router

    init(viewModel: SongEditScreenViewModel) {
        _viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            HStack(spacing: .zero) {
                Text("Title:")
                TextField("Title", text: $_viewModel.title)
                    .textFieldStyle(.roundedBorder)
            }
            Text(_viewModel.song.melody.description)
            Button {
                _router.navigate(to: SongEditScreenViewModel.Route.editMelody)
            } label: {
                Text("Edit melody")
            }
        }
        .navigationDestination(for: SongEditScreenViewModel.Route.self) { route in
            switch route {
                case .editMelody:
                    MelodyEditScreenView(
                        viewModel: MelodyEditScreenViewModel()
                    )
            }
        }
        .environment(_router)
    }
}

struct HarmonicaSong {
    let title: String
    let melody: [Melody]
}
