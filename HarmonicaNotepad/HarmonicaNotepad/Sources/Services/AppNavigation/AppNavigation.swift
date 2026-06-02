//
//  AppRouter.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 21.06.2025.
//

import SwiftUI

typealias MainRouter = AppRouterImpl<AppNavigationModel.Scope.Main>
typealias SongsListsRouter = AppRouterImpl<AppNavigationModel.Scope.SongsLists>
typealias SearchListRouter = AppRouterImpl<AppNavigationModel.Scope.SearchList>
typealias FavoritesRouter = AppRouterImpl<AppNavigationModel.Scope.Favorites>

@Observable
class AppNavigationModel {
    enum Scope {
        enum Main {}
        enum SongsLists {}
        enum SearchList {}
        enum Favorites {}
    }

    var mainRouter = MainRouter()
    var songsLists = SongsListsRouter()
    var searchList = SearchListRouter()
    var favoriteRouter = FavoritesRouter()

    var selectedTab: ContentTab = .songs
}
