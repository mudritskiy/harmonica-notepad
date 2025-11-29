//
//  FavoriteSong.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 29.11.2025.
//

import Foundation
import SwiftData

@Model
final class FavoriteSong {
    var songId: SongId
    var dateAdded: Date

    init(with songId: SongId) {
        self.songId = songId
        self.dateAdded = Date()
    }
}
