import Foundation

struct BackupPayload: Codable {
    static let currentFormatVersion = 1

    var formatVersion: Int
    var exportedAt: Date
    var songs: [SongBackupDTO]
    var songsLists: [SongsListBackupDTO]
    var songsListData: [SongsListDataBackupDTO]

    init(
        songs: [SongBackupDTO],
        songsLists: [SongsListBackupDTO],
        songsListData: [SongsListDataBackupDTO],
        exportedAt: Date
    ) {
        self.formatVersion = Self.currentFormatVersion
        self.exportedAt = exportedAt
        self.songs = songs
        self.songsLists = songsLists
        self.songsListData = songsListData
    }
}

struct SongBackupDTO: Codable {
    var id: SongId
    var title: String
    var artist: String
    var comments: String
    var melody: MelodyWrapper
    var additionalData: SongAdditionalData
}

struct SongsListBackupDTO: Codable {
    var id: SongsListId
    var createdDate: Date
    var name: String
    var color: String
    var comment: String
    var isDefault: Bool
}

struct SongsListDataBackupDTO: Codable {
    var id: SongsListDataId
    var songsListId: SongsListId
    var songId: SongId
    var addedDate: Date
}
