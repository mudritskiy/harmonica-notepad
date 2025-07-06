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
    @Relationship(deleteRule: .cascade, inverse: \Melody.song)
    var melody: Melody

    init(id: SongId, title: String, melody: Melody) {
        self.id = id
        self.title = title
        self.melody = melody
    }
}
