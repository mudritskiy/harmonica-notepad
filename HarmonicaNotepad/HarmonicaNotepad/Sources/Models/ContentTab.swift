//
//  ContentTab.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 04.01.2026.
//

enum ContentTab {
    case songs
    case lists
    case favorites
    case search
}

extension ContentTab {
    var title: String {
        switch self {
            case .songs: "Songs"
            case .lists: "Lists"
            case .favorites: "Favorites"
            case .search: "Search"
        }
    }

    func imageName(selectedTab: ContentTab) -> String {
        let isSelected: Bool = selectedTab == self
        return switch self {
            case .songs: isSelected ? "house.fill" : "house"
            case .lists: isSelected ? "list.bullet.rectangle": "list.bullet"
            case .favorites: isSelected ? "bookmark.fill" : "bookmark"
            case .search:  "magnifyingglass"
        }
    }
}

