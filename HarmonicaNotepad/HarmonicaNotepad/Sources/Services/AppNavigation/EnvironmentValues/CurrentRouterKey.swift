//
//  CurrentRouterKey.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 04.04.2026.
//

import SwiftUI

private struct CurrentRouterKey: EnvironmentKey {
    static let defaultValue: (any AppRouter)? = nil
}

extension EnvironmentValues {
    var currentRouter: (any AppRouter)? {
        get { self[CurrentRouterKey.self] }
        set { self[CurrentRouterKey.self] = newValue }
    }
}
