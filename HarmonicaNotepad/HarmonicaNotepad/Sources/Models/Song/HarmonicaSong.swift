//
//  HarmonicaSong.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import SwiftData

typealias SongId = String

@Model
final class HarmonicaSong {
    @Attribute(.unique) var id: SongId

    var title: String
    var artist: String
    var comments: String
    var isFavorite: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \Melody.song)
    var melody: Melody

    @Relationship(deleteRule: .nullify)
    var tags: [SongTag]?

    init(
        id: SongId,
        title: String,
        artist: String = "",
        comments: String = "",
        melody: Melody
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.comments = comments
        self.melody = melody
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
