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
    var selectedTab: ContentTab = .main

    init() {
        self.mainScreenViewModel = MainScreenViewModel()
    }
}

struct ContetnCoordinatorView: View {
    @Bindable private var _viewModel: ContetnCoordinatorViewModel

    init(viewModel: ContetnCoordinatorViewModel) {
        _viewModel = viewModel
    }

    var body: some View {
        TabView(selection: $_viewModel.selectedTab) {
            MainScreenView(viewModel: _viewModel.mainScreenViewModel)
                .tag(ContentTab.main)
                .tabItem {
                    Image(systemName: _viewModel.selectedTab == .main ? "house.fill" : "house")
                }
            NoteView()
                .tag(ContentTab.favorites)
                .tabItem {
                    Image(systemName: _viewModel.selectedTab == .favorites ? "bookmark.fill" : "bookmark")
                }

        }
    }
}
