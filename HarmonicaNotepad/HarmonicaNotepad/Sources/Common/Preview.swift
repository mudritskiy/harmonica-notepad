//
//  Preview.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 06.07.2025.
//

import MusicTheory
import SwiftData
import SwiftUI

struct Preview {
    let container: ModelContainer

    init() {
        container = SwiftDataCoreServiceImpl.shared.previewContainer()
    }

    func populate(with examples: [any PersistentModel]) {
        Task { @MainActor in
            examples.forEach { example in
                container.mainContext.insert(example)
            }
            try container.mainContext.save()
        }
    }

    func sampleSong() -> HarmonicaSong {
        let melody = sampleMelody()
        let song = HarmonicaSong(
            id: "0197e0f3-a7a7-74b7-b8a4-28fb69e56300",
            title: "All You Need Is Love",
            artist: "The Beatles",
            comments: "Chord progression, Strong Lyrics, Solid song structure (chord and lyrics have to come together), Ability to evoke reaction and emotion, and having that Special hook with certain musical interlude that can embed itself in your listeners’ brains.",
            melody: melody
        )
        song.tags = Array(sampleTags().prefix(3))
        return song
    }

    func sampleTags() -> [SongTag] {
        [
            SongTag(value: "pop"),
            SongTag(value: "rock"),
            SongTag(value: "classic"),
            SongTag(value: "jazz"),
            SongTag(value: "blues"),
            SongTag(value: "country"),
            SongTag(value: "metal"),
            SongTag(value: "hip-hop"),
            SongTag(value: "rap"),
            SongTag(value: "electronic"),
            SongTag(value: "world music"),
        ]
    }

    func sampleMelody() -> Melody {
        let layout = sampleLayout()
        let notes = sampleMelodyNotes(with: layout)
        let melody = Melody(
            key: layout.key,
            tempo: .default,
            notes: notes
        )
        return melody
    }

    func sampleMelodyNotes(with layout: HarmonicaLayout? = nil) -> [MelodyNote] {
        let layout: HarmonicaLayout = layout ?? sampleLayout()
        let notes = layout.notes.prefix(15).map {
            MelodyNote(note: $0)
        }
        return notes
    }

    func sampleLayout(with key: Key = .default) -> HarmonicaLayout {
        HarmonicaLayout.init(key: key)
    }
}
