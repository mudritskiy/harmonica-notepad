//
//  MainScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 21.06.2025.
//

import SwiftUI

@Observable
final class MainScreenViewModel {
    enum Route: Hashable {
        case editSong
    }
}

struct MainScreenView: View {
    @Bindable private var _viewModel: MainScreenViewModel
    @Environment(MainRouter.self) private var _router

    init(viewModel: MainScreenViewModel) {
        _viewModel = viewModel
    }

    var body: some View {
        List {
            Button {
                _router.navigate(to: MainScreenViewModel.Route.editSong)
            } label: {
                Text("Open song edit")
            }
        }
        .navigationDestination(for: MainScreenViewModel.Route.self) { route in
            switch route {
                case .editSong:
                    SongEditScreenView(
                        viewModel: SongEditScreenViewModel()
                    )
            }
        }
        .environment(_router)
    }
}
