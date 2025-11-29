//
//  HarmonicaSong.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import SwiftData
import SwiftUI

typealias SongId = UUID

enum HarmonicaSongProperty: CaseIterable {
    case title
    case artist
    case comments
}

protocol HarmonicaSongProperties {
    var title: String { get set }
    var artist: String { get set }
    var comments: String { get set }
}

extension HarmonicaSongProperties {
    func placeholder(for property: HarmonicaSongProperty) -> String {
        switch property {
            case .title: "Title"
            case .artist: "Artist"
            case .comments: "Comments"
        }
    }
}

@Model
final class HarmonicaSong: HarmonicaSongProperties {
    @Attribute(.unique) var id: SongId

    var title: String
    var artist: String
    var comments: String
    var isFavorite: Bool = false

    var melody: MelodyWrapper

    @Relationship(deleteRule: .nullify)
    var tags: [SongTag]?

    init(
        id: SongId,
        title: String,
        artist: String = "",
        comments: String = "",
        melody: MelodyWrapper
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.comments = comments
        self.melody = melody
    }

    static func new() -> HarmonicaSong {
        HarmonicaSong(
            id: SongId(),
            title: .empty,
            melody: MelodyWrapper(Melody())
        )
    }
}

@Model
final class SongTag {
    @Attribute(.unique) var value: String

    @Relationship(deleteRule: .nullify)
    var song: [HarmonicaSong]?

    init(value: String) {
        self.value = value
    }
}
