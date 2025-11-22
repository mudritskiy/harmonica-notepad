//
//  ContentView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 11.07.2024.
//

import SwiftData
import SwiftUI
import MusicTheory

enum ContentTab {
    case main
    case favorites
    case search
}

struct ContentView: View {
    var body: some View {
        ContentCoordinatorView(viewModel: ContentCoordinatorViewModel())
    }
}

@Observable
final class ContentCoordinatorViewModel {
    // MARK: - Dependencies
    private let _swiftDataCoreService: SwiftDataCoreService

    // MARK: - Properties
    let mainScreenViewModel: MainScreenViewModel
    let songListViewModel: SongListViewModel
    let container: ModelContainer

    // MARK: - Init
    init(
        swiftDataCoreService: SwiftDataCoreService = SwiftDataCoreServiceImpl.shared
    ) {
        mainScreenViewModel = MainScreenViewModel()
        songListViewModel = SongListViewModel()
        _swiftDataCoreService = swiftDataCoreService
        container = swiftDataCoreService.container()
    }
}

struct ContentCoordinatorView: View {
    // MARK: - Properties
    @Bindable private var _viewModel: ContentCoordinatorViewModel
    @Environment(AppNavigationModel.self) private var _appNavigation

    // MARK: - Init
    init(
        viewModel: ContentCoordinatorViewModel
    ) {
        _viewModel = viewModel
    }

    // MARK: - Render
    var body: some View {
        @Bindable var appNavigation = _appNavigation

        TabView(selection: $appNavigation.selectedTab) {

            Tab("Songs", systemImage: appNavigation.selectedTab == .main ? "house.fill" : "house", value: ContentTab.main) {
                NavigationStack(path: $appNavigation.mainRouter.path) {
                    SongListView(viewModel: _viewModel.songListViewModel)
                    //                MainScreenView(viewModel: _viewModel.mainScreenViewModel)
                }
//                .tag(ContentTab.main)
//                .tabItem {
//                    Image(systemName: appNavigation.selectedTab == .main ? "house.fill" : "house")
//                }
                .environment(appNavigation.mainRouter)
            }

            Tab("Favorites", systemImage: appNavigation.selectedTab == .favorites ? "bookmark.fill" : "bookmark", value: ContentTab.favorites) {
                NavigationStack(path: $appNavigation.favoriteRouter.path) {
                    NoteView()
                }
//                .tag(ContentTab.favorites)
//                .tabItem {
//                    Image(systemName: appNavigation.selectedTab == .favorites ? "bookmark.fill" : "bookmark")
//                }
                .environment(appNavigation.favoriteRouter)
            }

            Tab("Search", systemImage: "magnifyingglass", value: ContentTab.search, role: .search) {
                NavigationStack(path: $appNavigation.mainRouter.path) {
                    SearchListView()
                }
                .environment(appNavigation.mainRouter)
            }
        }
        .environment(\.currentTab, $appNavigation.selectedTab)
        .modelContainer(_viewModel.container)
    }
}
