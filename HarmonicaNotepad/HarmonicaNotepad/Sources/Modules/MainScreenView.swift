//
//  MainScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 21.06.2025.
//

import SwiftUI

typealias MainScreenRouter = BaseRouter<MainScreenViewModel.Route>

@Observable
final class MainScreenViewModel {
    enum Route: Hashable {
        case some
    }

    var router: MainScreenRouter

    init(router: MainScreenRouter = MainScreenRouter()) {
        self.router = router
    }

    func openEditMelody() {
        router.navigate(to: .some)
    }
}

struct MainScreenView: View {
    @Bindable var viewModel: MainScreenViewModel

    var body: some View {
        NavigationStack(path: $viewModel.router.path) {
            Text("Hello, World!")
                .navigationDestination(for: MainScreenViewModel.Route.self) { route in
                    switch route {
                        case .some:
                            MelodyEditScreenView(
                                viewModel: MelodyEditScreenViewModel()
                            )
                    }
                }
            Button {
                viewModel.openEditMelody()
            } label: {
                Text("Open Detail")
            }
        }
    }
}
