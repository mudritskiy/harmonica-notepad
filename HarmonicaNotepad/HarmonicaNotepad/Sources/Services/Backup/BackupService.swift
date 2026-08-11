import Foundation
import SwiftData

enum BackupError: Error, LocalizedError {
    case unsupportedFormatVersion(Int)
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
            case .unsupportedFormatVersion(let version):
                "This backup was made with a newer app version (format \(version)) and can't be restored here."
            case .encodingFailed:
                "Could not create the backup file."
            case .decodingFailed:
                "This file isn't a valid Harmonica Notepad backup."
        }
    }
}

protocol BackupService {
    func exportPayload(from context: ModelContext) throws -> BackupPayload
    func encode(_ payload: BackupPayload) throws -> Data
    func decode(_ data: Data) throws -> BackupPayload
    func restore(_ payload: BackupPayload, into context: ModelContext) throws
}

struct BackupServiceImpl: BackupService {
    func exportPayload(from context: ModelContext) throws -> BackupPayload {
        let songs = try context.fetch(FetchDescriptor<HarmonicaSong>())
        let songsLists = try context.fetch(FetchDescriptor<SongsList>())
        let songsListData = try context.fetch(FetchDescriptor<SongsListData>())

        return BackupPayload(
            songs: songs.map {
                SongBackupDTO(
                    id: $0.id,
                    title: $0.title,
                    artist: $0.artist,
                    comments: $0.comments,
                    melody: $0.melody,
                    additionalData: $0.extra
                )
            },
            songsLists: songsLists.map {
                SongsListBackupDTO(
                    id: $0.id,
                    createdDate: $0.createdDate,
                    name: $0.name,
                    color: $0.color,
                    comment: $0.comment,
                    isDefault: $0.isDefault
                )
            },
            songsListData: songsListData.map {
                SongsListDataBackupDTO(
                    id: $0.id,
                    songsListId: $0.songsList?.id ?? SongsListId(),
                    songId: $0.songId,
                    addedDate: $0.addedDate
                )
            },
            exportedAt: .now
        )
    }

    func encode(_ payload: BackupPayload) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(payload) else {
            throw BackupError.encodingFailed
        }
        return data
    }

    func decode(_ data: Data) throws -> BackupPayload {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let payload = try? decoder.decode(BackupPayload.self, from: data) else {
            throw BackupError.decodingFailed
        }
        guard payload.formatVersion <= BackupPayload.currentFormatVersion else {
            throw BackupError.unsupportedFormatVersion(payload.formatVersion)
        }
        return payload
    }

    func restore(_ payload: BackupPayload, into context: ModelContext) throws {
        do {
            let existingLinks = try context.fetch(FetchDescriptor<SongsListData>())
            existingLinks.forEach { context.delete($0) }

            let existingLists = try context.fetch(FetchDescriptor<SongsList>())
            existingLists.forEach { context.delete($0) }

            let existingSongs = try context.fetch(FetchDescriptor<HarmonicaSong>())
            existingSongs.forEach { context.delete($0) }

            for songDTO in payload.songs {
                let song = HarmonicaSong(
                    id: songDTO.id,
                    title: songDTO.title,
                    artist: songDTO.artist,
                    comments: songDTO.comments,
                    melody: songDTO.melody
                )
                song.extra = songDTO.additionalData
                context.insert(song)
            }

            var listsById: [SongsListId: SongsList] = [:]
            for listDTO in payload.songsLists {
                let list = SongsList(
                    name: listDTO.name,
                    color: listDTO.color,
                    comment: listDTO.comment,
                    isDefault: listDTO.isDefault
                )
                list.id = listDTO.id
                list.createdDate = listDTO.createdDate
                listsById[listDTO.id] = list
                context.insert(list)
            }

            for linkDTO in payload.songsListData {
                guard let list = listsById[linkDTO.songsListId] else { continue }
                let link = SongsListData(songsList: list, songId: linkDTO.songId, addedDate: linkDTO.addedDate)
                context.insert(link)
            }

            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
