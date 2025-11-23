//
//  SongService.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 23.11.2025.
//

import SwiftData
import SwiftUI

@ModelActor
actor SongService {
    func save(_ data: HarmonicaSong) async {
        modelContext.insert(data)
        // TODO: case oparation failed
        try? modelContext.save()
    }

    func fetch(by id: SongId) async -> HarmonicaSong? {
        let descriptor = _songDescriptor(by: id)
        guard let song = try? modelContext.fetch(descriptor).first else { return nil }
        return song
    }

    private func _songDescriptor(by id: SongId) -> FetchDescriptor<HarmonicaSong> {
        var descriptor = FetchDescriptor<HarmonicaSong>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return descriptor
    }
}
