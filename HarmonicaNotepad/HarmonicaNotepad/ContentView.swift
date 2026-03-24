//
//  ContentView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 11.07.2024.
//

import SwiftData
import SwiftUI
import MusicTheory

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

    private let _allTabs: [ContentTab] = [.songs, .lists, .favorites, .search]

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
            ForEach(_allTabs, id: \.self) { tab in
                Tab(
                    tab.title,
                    systemImage: tab.imageName(selectedTab: appNavigation.selectedTab),
                    value: tab
                ) {
                    switch tab {
                        case .songs:
                            @Bindable var router = appNavigation.mainRouter
                            NavigationStack(path: $router.path) {
                                SongListView(viewModel: _viewModel.songListViewModel)
                            }
                            .environment(router)
                        case .lists:
                            @Bindable var router = appNavigation.songsLists
                            NavigationStack(path: $router.path) {
                                SongsListsView()
                            }
                            .environment(router)
                        case .favorites:
                            @Bindable var router = appNavigation.favoriteRouter
                            NavigationStack(path: $router.path) {
                                NoteView()
                            }
                            .environment(router)
                        case .search:
                            @Bindable var router = appNavigation.mainRouter
                            NavigationStack(path: $router.path) {
                                SearchListView()
                            }
                            .environment(router)
                    }
                }
            }
        }
        .fontDesign(.rounded)
        .environment(\.currentTab, $appNavigation.selectedTab)
        .modelContainer(_viewModel.container)
    }
}
