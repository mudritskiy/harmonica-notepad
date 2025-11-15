//
//  SongEditScreenViewModel.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 03.11.2025.
//

import MusicTheory
import SwiftData
import SwiftUI

final class SongProperties: HarmonicaSongProperties {
    var title: String
    var artist: String
    var comments: String

    private init(
        title: String,
        artist: String,
        comments: String
    ) {
        self.title = title
        self.artist = artist
        self.comments = comments
    }

    convenience init(with propertiesHolder: HarmonicaSongProperties) {
        self.init(
            title: propertiesHolder.title,
            artist: propertiesHolder.artist,
            comments: propertiesHolder.comments
        )
    }

    convenience init() {
        self.init(
            title: .empty,
            artist: .empty,
            comments: .empty
        )
    }
}

@Observable
final class SongEditScreenViewModel {
    enum Route: Hashable {
        case editMelody
    }

    var modelContext: ModelContext? = nil

    var songId: SongId
    var melody: Melody

    var songProperties: HarmonicaSongProperties
    let onSave: (HarmonicaSongProperties) -> Void

//    var titleWidth: CGFloat {
//        let displayText = songProperties.title.isEmpty ? "Title" : songProperties.title
//        let font = UIFont.systemFont(ofSize: 17)
//        let attributes = [NSAttributedString.Key.font: font]
//        let size = (displayText as NSString).size(withAttributes: attributes)
//        return size.width
//    }

    func isMelodyAvailable() -> Bool {
        !melody.notes.isEmpty
    }

    @ObservationIgnored
    lazy var melodyEditViewModel: MelodyEditScreenViewModel = {
        MelodyEditScreenViewModel(melody: melody, onApplyTap: { [weak self] in
            guard let self else { return }
            melody = Melody(
                key: melodyEditViewModel.key,
                tempo: melodyEditViewModel.tempo,
                notes: melodyEditViewModel.notes
            )
        }, onApplyTap2: { _ in })
    }()

    init(song: HarmonicaSong? = nil, onSave: @escaping (HarmonicaSongProperties) -> Void) {
        if let song = song {
            self.songProperties = SongProperties(with: song)
            self.songId = song.id
            self.melody = song.melody.value
        } else {
            self.songProperties = SongProperties()
            self.songId = SongId(UUID().uuidString)
            self.melody = Melody()
        }
        self.onSave = onSave
    }

    func saveProperties() {
        onSave(songProperties)
    }

    func save() {
        guard let container = modelContext?.container else { return }
        Task.detached(priority: .background) {
            let song = HarmonicaSong(
                id: self.songId,
                title: self.songProperties.title,
                artist: self.songProperties.artist,
                comments: self.songProperties.comments,
                melody: MelodyWrapper(self.melody)
            )
            let actor = SongService(modelContainer: container)
            await actor.save(song)
        }
    }
}

extension SongEditScreenViewModel {
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
                    set: { self.songProperties.artist = $0 }
                )
            case .comments:
                Binding(
                    get: { self.songProperties.comments },
                    set: { self.songProperties.comments = $0 }
                )
        }
    }
}

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
