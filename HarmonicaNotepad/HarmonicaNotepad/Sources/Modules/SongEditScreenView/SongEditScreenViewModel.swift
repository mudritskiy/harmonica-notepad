//
//  SongEditScreenViewModel.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 03.11.2025.
//

import Combine
import MusicTheory
import SwiftData
import SwiftUI

@Observable
final class SongEditScreenViewModel {
    enum Route: Hashable {
        case editMelody
    }

    // MARK: - Properties
    var modelContext: ModelContext? = nil
    var songId: SongId
    var melody: Melody
    var songProperties: HarmonicaSongProperties

    @ObservationIgnored let songProperiesPublisher = PassthroughSubject<HarmonicaSongProperties, Never>()

    // MARK: - Init
    init(song: HarmonicaSong? = nil) {
        if let song = song {
            self.songProperties = SongEditableProperties(with: song)
            self.songId = song.id
            self.melody = song.melody.value
        } else {
            self.songProperties = SongEditableProperties()
            self.songId = UUID()
            self.melody = Melody()
        }
    }

    // MARK: - View Actions
    func isMelodyAvailable() -> Bool {
        !melody.notes.isEmpty
    }

    func saveProperties() {
        songProperiesPublisher.send(songProperties)
    }

    func binding(for property: HarmonicaSongProperty) -> Binding<String> {
        switch property {
            case .title:
                Binding(
                    get: { self.songProperties.title },
                    set: { self.songProperties.title = $0 }
                )
            case .artist:
                Binding(
                    get: { self.songProperties.artist },
                    set: {
                        guard self.songProperties.artist != $0 else { return }
                        self.songProperties.artist = $0
                    }
                )
            case .comments:
                Binding(
                    get: { self.songProperties.comments },
                    set: { self.songProperties.comments = $0 }
                )
        }
    }
}
