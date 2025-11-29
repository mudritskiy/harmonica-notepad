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
