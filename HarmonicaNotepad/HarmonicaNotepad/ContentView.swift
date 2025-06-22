//
//  ContentView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 11.07.2024.
//

import SwiftUI
import MusicTheory

enum ContentTab {
    case main
    case favorites
}

struct ContentView: View {
    var body: some View {
        ContetnCoordinatorView(viewModel: ContetnCoordinatorViewModel())
    }
}

@Observable
final class ContetnCoordinatorViewModel {
    let mainScreenViewModel: MainScreenViewModel

    init() {
        self.mainScreenViewModel = MainScreenViewModel()
    }
}

struct ContetnCoordinatorView: View {
    @Bindable private var _viewModel: ContetnCoordinatorViewModel

    @Environment(AppNavigationModel.self) private var _appNavigation

    init(viewModel: ContetnCoordinatorViewModel) {
        _viewModel = viewModel
    }

    var body: some View {
        @Bindable var appNavigation = _appNavigation

        TabView(selection: $appNavigation.selectedTab) {

            NavigationStack(path: $appNavigation.mainRouter.path) {
                MainScreenView(viewModel: _viewModel.mainScreenViewModel)
            }
            .tag(ContentTab.main)
            .tabItem {
                Image(systemName: appNavigation.selectedTab == .main ? "house.fill" : "house")
            }
            .environment(appNavigation.mainRouter)

            NavigationStack(path: $appNavigation.favoriteRouter.path) {
                NoteView()
            }
            .tag(ContentTab.favorites)
            .tabItem {
                Image(systemName: appNavigation.selectedTab == .favorites ? "bookmark.fill" : "bookmark")
            }
            .environment(appNavigation.favoriteRouter)

        }
        .environment(\.currentTab, $appNavigation.selectedTab)
    }
}
