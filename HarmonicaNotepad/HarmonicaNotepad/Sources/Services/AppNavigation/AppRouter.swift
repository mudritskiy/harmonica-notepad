//
//  AppRouter.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 04.04.2026.
//

import SwiftUI

protocol AppRouter: ObservableObject {
    var path: NavigationPath { get set }
    var isEmpty: Bool { get }
    func navigate(to route: any Hashable)
    func navigateBack()
    func popToRoot()
}

extension AppRouter {
    var isEmpty: Bool { path.isEmpty }

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

// MARK: - AppRouter
@Observable
final class AppRouterImpl<Scope>: AppRouter {
    var path = NavigationPath()
}

