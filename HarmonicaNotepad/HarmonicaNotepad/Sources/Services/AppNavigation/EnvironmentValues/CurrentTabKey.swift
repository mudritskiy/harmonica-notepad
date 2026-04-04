//
//  CurrentTabKey.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 04.04.2026.
//

import SwiftUI

struct CurrentTabKey: EnvironmentKey {
    static var defaultValue: Binding<ContentTab> = .constant(.songs)
}

extension EnvironmentValues {
    var currentTab: Binding<ContentTab> {
        get { self[CurrentTabKey.self] }
        set { self[CurrentTabKey.self] = newValue }
    }
}
