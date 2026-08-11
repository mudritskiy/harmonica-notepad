import Testing
import SwiftData
import Foundation
import MusicTheory
@testable import HarmonicaNotepad

@Suite("BackupService")
struct BackupServiceTests {
    @Test("round-trips songs, lists, and list membership through encode/decode")
    func roundTrip() throws {
        let container = SwiftDataCoreServiceImpl.shared.previewContainer()
        let context = ModelContext(container)

        let song = HarmonicaSong.new()
        song.title = "Oh Susanna"
        song.artist = "Traditional"
        song.isFavorite = true
        let melody = Melody(
            key: Key(type: .g),
            tempo: Tempo(bpm: 140),
            notes: [
                MelodyNote(note: .default, value: NoteValue(type: .quarter)),
                MelodyNote(
                    note: HarmonicaNote(hole: 2, direction: .draw, technique: .natural, basePitch: .default),
                    value: NoteValue(type: .eighth)
                )
            ]
        )
        song.melody = MelodyWrapper(melody)
        context.insert(song)

        let list = SongsList(name: "Favorites Live Set")
        context.insert(list)
        let link = SongsListData(songsList: list, songId: song.id)
        context.insert(link)
        try context.save()

        let service = BackupServiceImpl()
        let payload = try service.exportPayload(from: context)
        let data = try service.encode(payload)
        let decoded = try service.decode(data)

        #expect(decoded.songs.count == 1)
        #expect(decoded.songs[0].title == "Oh Susanna")
        let isFavorite: Bool? = decoded.songs[0].additionalData.get(for: .isFavorite)
        #expect(isFavorite == true)
        #expect(decoded.songsLists.count == 1)
        #expect(decoded.songsLists[0].name == "Favorites Live Set")
        #expect(decoded.songsListData.count == 1)
        #expect(decoded.songsListData[0].songId == song.id)

        let decodedMelody = decoded.songs[0].melody
        #expect(decodedMelody.key == Key(type: .g))
        #expect(decodedMelody.bpm == 140)
        #expect(decodedMelody.notes.count == 2)
        #expect(decodedMelody.notes[0].note.position == HarmonicaNote.default.position)
        // NoteValueTypeWrapper only persists `rate`, not `description`, so compare on
        // rate (the value actually used for duration math) rather than full NoteValue equality.
        #expect(decodedMelody.notes[0].value.rate == NoteValue(type: .quarter).rate)
        #expect(decodedMelody.notes[1].note.hole == 2)
        #expect(decodedMelody.notes[1].note.direction == .draw)
        #expect(decodedMelody.notes[1].note.technique == .natural)
        #expect(decodedMelody.notes[1].value.rate == NoteValue(type: .eighth).rate)
    }

    @Test("restore replaces existing data rather than merging")
    func restoreReplacesExisting() throws {
        let container = SwiftDataCoreServiceImpl.shared.previewContainer()
        let context = ModelContext(container)

        let staleSong = HarmonicaSong.new()
        staleSong.title = "Stale Song"
        context.insert(staleSong)

        let staleList = SongsList(name: "Stale List")
        context.insert(staleList)
        let staleLink = SongsListData(songsList: staleList, songId: SongId())
        context.insert(staleLink)

        try context.save()

        let service = BackupServiceImpl()
        let incomingSongId = SongId()
        let incomingListId = SongsListId()
        let incomingSong = SongBackupDTO(
            id: incomingSongId,
            title: "Restored Song",
            artist: "",
            comments: "",
            melody: MelodyWrapper(Melody()),
            additionalData: SongAdditionalData()
        )
        let incomingList = SongsListBackupDTO(
            id: incomingListId,
            createdDate: Date(timeIntervalSince1970: 0),
            name: "Restored List",
            color: "FF5733",
            comment: "",
            isDefault: false
        )
        let incomingLink = SongsListDataBackupDTO(
            id: "\(incomingListId)|\(incomingSongId)",
            songsListId: incomingListId,
            songId: incomingSongId,
            addedDate: Date(timeIntervalSince1970: 0)
        )
        let payload = BackupPayload(
            songs: [incomingSong],
            songsLists: [incomingList],
            songsListData: [incomingLink],
            exportedAt: Date(timeIntervalSince1970: 0)
        )

        try service.restore(payload, into: context)

        let songs = try context.fetch(FetchDescriptor<HarmonicaSong>())
        #expect(songs.count == 1)
        #expect(songs[0].title == "Restored Song")

        let lists = try context.fetch(FetchDescriptor<SongsList>())
        #expect(lists.count == 1)
        #expect(lists[0].name == "Restored List")

        let links = try context.fetch(FetchDescriptor<SongsListData>())
        #expect(links.count == 1)
        #expect(links[0].songId == incomingSongId)
        #expect(links[0].songsList?.id == incomingListId)
    }

    @Test("restoring onto matching existing ids does not throw or duplicate")
    func restoreOntoMatchingIds() throws {
        let container = SwiftDataCoreServiceImpl.shared.previewContainer()
        let context = ModelContext(container)

        let song = HarmonicaSong.new()
        song.title = "Same Device Song"
        context.insert(song)

        let list = SongsList(name: "Same Device List")
        context.insert(list)
        let link = SongsListData(songsList: list, songId: song.id)
        context.insert(link)
        try context.save()

        let service = BackupServiceImpl()
        let payload = try service.decode(try service.encode(try service.exportPayload(from: context)))

        try service.restore(payload, into: context)

        let songs = try context.fetch(FetchDescriptor<HarmonicaSong>())
        #expect(songs.count == 1)
        #expect(songs[0].title == "Same Device Song")
        #expect(songs[0].id == song.id)

        let lists = try context.fetch(FetchDescriptor<SongsList>())
        #expect(lists.count == 1)
        #expect(lists[0].name == "Same Device List")
        #expect(lists[0].id == list.id)

        let links = try context.fetch(FetchDescriptor<SongsListData>())
        #expect(links.count == 1)
        #expect(links[0].songId == song.id)
        #expect(links[0].songsList?.id == list.id)
    }

    @Test("decoding an unsupported future format version fails")
    func rejectsUnsupportedFormatVersion() throws {
        let service = BackupServiceImpl()
        let futurePayload = """
        {"formatVersion":999,"exportedAt":"2026-01-01T00:00:00Z","songs":[],"songsLists":[],"songsListData":[]}
        """.data(using: .utf8)!

        #expect(throws: BackupError.self) {
            try service.decode(futurePayload)
        }
    }
}
