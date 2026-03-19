//
//  FavoritesService.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 29.11.2025.
//

import SwiftData
import SwiftUI

protocol FavoritesService {
    func isFavorited(songId: SongId, in context: ModelContext) -> Bool
    func addFavorite(by songId: SongId, in context: ModelContext)
    func removeFavorite(by songId: SongId, in context: ModelContext)
}

final class FavoritesServiceImpl: FavoritesService {
    static let shared: FavoritesService = FavoritesServiceImpl()

    func isFavorited(songId: SongId, in context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<FavoriteSong>(predicate: #Predicate { $0.songId == songId })
        let records = try? context.fetchCount(descriptor)
        return records ?? 0 > 0
    }

    func addFavorite(by songId: SongId, in context: ModelContext) {
        let favorite = FavoriteSong(with: songId)
        context.insert(favorite)
        do {
            try context.save()
        } catch {
            assertionFailure("\(songId)")
        }
    }

    func removeFavorite(by songId: SongId, in context: ModelContext) {
        if let favorite = _fetchFavorite(by: songId, in: context) {
            context.delete(favorite)
            do {
                try context.save()
            } catch {
                assertionFailure("\(songId)")
            }
        }
    }

    private func _fetchFavorite(by songId: SongId, in context: ModelContext) -> FavoriteSong? {
        let descriptor = FetchDescriptor<FavoriteSong>(predicate: #Predicate { $0.songId == songId })
        return try? context.fetch(descriptor).first
    }
}

protocol SongsListsService {
    func isInList(songId: SongId, in context: ModelContext) -> Bool
    func add(_ songId: SongId, to songsListId: SongsListId, in context: ModelContext)
    func remove(by songId: SongId, in context: ModelContext)
    func removeSong(_ songId: SongId, from songsList: SongsList, in context: ModelContext)
    func removeFromAllLists(_ songId: SongId, in context: ModelContext)
}

final class SongsListsServiceImpl: SongsListsService {
    static let shared: SongsListsService = SongsListsServiceImpl()

    func isInList(songId: SongId, in context: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<SongsList>(
            predicate: #Predicate { $0.songsData.contains(where: { $0.songId == songId })
            })
        let records = try? context.fetchCount(descriptor)
        return records ?? 0 > 0
    }

//    func add1(_ songId: SongId, to songsListId: SongsListId, in context: ModelContext) {
//        let data = SongsListData(songsListId: songsListId, songId: songId)
//        context.insert(data)
//        do {
//            try context.save()
//        } catch {
//            assertionFailure("\(songId)")
//        }
//    }

    func add(_ songId: SongId, to songsListId: SongsListId, in context: ModelContext) {
        // 1. Fetch the SongsList first (very important!)
        guard let songsList = try? context.fetch(
            FetchDescriptor<SongsList>(predicate: #Predicate { $0.id == songsListId })
        ).first else {
            assertionFailure("SongsList not found")
            return
        }

        // 2. Create SongsListData with the actual relationship
        let data = SongsListData(songsList: songsList, songId: songId)

        context.insert(data)

        do {
            try context.save()
        } catch {
            assertionFailure("Failed to save SongsListData: \(error)")
        }
    }

    func remove(by songId: SongId, in context: ModelContext) {
        if let data = _fetch(by: songId, in: context).first {
            context.delete(data)
            do {
                try context.save()
            } catch {
                assertionFailure("\(songId)")
            }
        }
    }

    private func _fetch(by songId: SongId, in context: ModelContext) -> [SongsListData] {
        let descriptor = FetchDescriptor<SongsListData>(predicate: #Predicate { $0.songId == songId })
        return (try? context.fetch(descriptor)) ?? []
    }

    // On SongsList or in a dedicated service/manager
    func removeSong(_ songId: SongId, from songsList: SongsList, in context: ModelContext) {
        let songsListId = songsList.id
        let predicate = #Predicate<SongsListData> { data in
            data.songsList?.id == songsListId && data.songId == songId
        }

        let descriptor = FetchDescriptor<SongsListData>(
            predicate: predicate
//            sortBy: [SortDescriptor(\.addedDate)]   // optional
        )

        do {
            if let join = try context.fetch(descriptor).first {
                context.delete(join)
                try context.save()
                // No need to manually nil anything – inverse relationship cleans up
            }
        } catch {
            assertionFailure("Remove failed for \(songId) in list \(songsList.name): \(error)")
        }
    }

    func removeFromAllLists(_ songId: SongId, in context: ModelContext) {
        let predicate = #Predicate<SongsListData> { $0.songId == songId }

        let descriptor = FetchDescriptor<SongsListData>(predicate: predicate)

        do {
            let items = try context.fetch(descriptor)
            for item in items {
                context.delete(item)
            }
            try context.save()
        } catch {
            assertionFailure("Global remove failed for \(songId): \(error)")
        }
    }
}
