//
//  SearchListDestinations.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 04.04.2026.
//

import SwiftUI

// MARK: - Route
enum SearchListRoute: Hashable {
    case showSong(HarmonicaSong)

    static func == (lhs: SearchListRoute, rhs: SearchListRoute) -> Bool {
        switch(lhs, rhs) {
            case let (.showSong(lhsSong), .showSong(rhsSong)):
                return lhsSong == rhsSong
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
            case .showSong(let song):
                hasher.combine(song)
        }
    }
}

// MARK: - Destination
struct SearchListDestinations: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: SearchListRoute.self) { route in
                switch route {
                    case .showSong(let song): SongScreenView(song: song)
                }
            }
    }
}
