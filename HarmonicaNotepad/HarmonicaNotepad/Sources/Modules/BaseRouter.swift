//
//  AppRouter.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 21.06.2025.
//

import SwiftUI

@Observable
class BaseRouter<Route: Hashable> {
    var path = NavigationPath()
    var isEmpty: Bool { path.isEmpty }

    //MARK: - Public
    func navigate(to route: Route) {
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
