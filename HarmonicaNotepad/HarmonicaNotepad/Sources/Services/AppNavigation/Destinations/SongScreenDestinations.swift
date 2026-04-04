//
//  SongScreenDestinations.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 04.04.2026.
//

import SwiftUI

// MARK: - Route
enum SongScreenRoute: Hashable {
    case editMelody(MelodyEditScreenViewModel)

    static func == (lhs: SongScreenRoute, rhs: SongScreenRoute) -> Bool {
        switch(lhs, rhs) {
            case (.editMelody, .editMelody):
                return true
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
            case .editMelody(let vm):
                hasher.combine(ObjectIdentifier(vm))
        }
    }
}

// MARK: - Destination
struct SongScreenDestinations: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: SongScreenRoute.self) { route in
                switch route {
                    case .editMelody(let viewModel): MelodyEditScreenView(viewModel: viewModel)
                }
            }
    }
}
