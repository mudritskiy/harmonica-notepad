//
//  SongsListData.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.11.2025.
//

import SwiftUI
import SwiftData
import MusicTheory

typealias SongsListDataId = String

@Model
final class SongsListData {
    @Attribute(.unique) var id: SongsListDataId

    var songsList: SongsList?
    var songId: SongId
    var addedDate: Date = Date()

    init(
        songsList: SongsList,
        songId: SongId,
        addedDate: Date = Date()
    ) {
        self.id = "\(songsList.id)|\(songId)"
        self.songsList = songsList
        self.songId = songId
        self.addedDate = addedDate
    }
}
