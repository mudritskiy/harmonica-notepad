//
//  SongsList.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.11.2025.
//

import SwiftUI
import SwiftData

typealias SongsListId = UUID

@Model
final class SongsList {
    @Attribute(.unique) var id: SongsListId = UUID()
    var createdDate: Date = Date()
    var name: String
    var color: String = "FF5733"
    var comment: String = ""
    var isDefault: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \SongsListData.songsList)
    var songsData: [SongsListData] = []

    init(name: String, color: String = "FF5733", comment: String = "", isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.comment = comment
        self.isDefault = isDefault
    }
}
