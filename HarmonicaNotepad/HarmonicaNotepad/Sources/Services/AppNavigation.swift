//
//  AppRouter.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 21.06.2025.
//

import SwiftUI

typealias MainRouter = AppRouter<AppNavigationModel.Scope.Main>
typealias FavoritesRouter = AppRouter<AppNavigationModel.Scope.Favorites>

// MARK: - AppNavigationModel
@Observable
class AppNavigationModel {
    enum Scope {
        enum Main {}
        enum Favorites {}
    }

    var mainRouter = MainRouter()
    var favoriteRouter = FavoritesRouter()

    var selectedTab: ContentTab = .main
}

// MARK: - AppRouter
@Observable
final class AppRouter<Scope> {
    var path = NavigationPath()

    var isEmpty: Bool { path.isEmpty }

    //MARK: - Public
    func navigate(to route: any Hashable) {
        path.append(route)
    }

    func navigateBack() {
        guard !isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}

// MARK: - EnvironmentKey
struct CurrentTabKey: EnvironmentKey {
    static var defaultValue: Binding<ContentTab> = .constant(.main)
}

extension EnvironmentValues {
    var currentTab: Binding<ContentTab> {
        get { self[CurrentTabKey.self] }
        set { self[CurrentTabKey.self] = newValue }
    }
}

