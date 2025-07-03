//
//  HarmonicaSong.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import SwiftData

typealias SongId = String//Identified<HarmonicaSong>

@Model
final class HarmonicaSong: Sendable {
    @Attribute(.unique) var id: SongId
    var title: String
    var melody: Melody

    init(id: SongId, title: String, melody: Melody) {
        self.id = id
        self.title = title
        self.melody = melody
    }
}

//@Model
//final class HarmonicaSongDataModel {
//    @Attribute(.unique) var id: String //SongId
//    var title: String
//
//    init(id: SongId, title: String) {
//        self.id = id.rawValue
//        self.title = title
//    }
//}
