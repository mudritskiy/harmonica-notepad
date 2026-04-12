//
//  HarmonicaSong.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import SwiftData
import SwiftUI

typealias SongId = UUID

enum HarmonicaSongProperty: CaseIterable {
    case title
    case artist
    case comments
}

protocol HarmonicaSongProperties {
    var title: String { get set }
    var artist: String { get set }
    var comments: String { get set }
}

extension HarmonicaSongProperties {
    func placeholder(for property: HarmonicaSongProperty) -> String {
        switch property {
            case .title: "Title"
            case .artist: "Artist"
            case .comments: "Comments"
        }
    }
}

@Model
final class HarmonicaSong: HarmonicaSongProperties {
    @Attribute(.unique) var id: SongId

    var title: String
    var artist: String
    var comments: String

    var melody: MelodyWrapper

    private var _additionalData: Data?

    init(
        id: SongId,
        title: String,
        artist: String = "",
        comments: String = "",
        melody: MelodyWrapper
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.comments = comments
        self.melody = melody
    }

    static func new() -> HarmonicaSong {
        HarmonicaSong(
            id: SongId(),
            title: .empty,
            melody: MelodyWrapper(Melody())
        )
    }
}

extension HarmonicaSong {
    var extra: SongAdditionalData {
        get {
            guard let data = _additionalData,
                  let decoded = try? JSONDecoder().decode(SongAdditionalData.self, from: data) else {
                return SongAdditionalData()
            }
            return decoded
        }
        set {
            _additionalData = try? JSONEncoder().encode(newValue)
        }
    }

    func setExtraValue<T: Encodable>(_ value: T?, for key: SongAdditionalKey) {
        var data = extra
        data.set(value, for: key)
        extra = data
    }

    var isFavorite: Bool {
        get { extra.get(for: .isFavorite) ?? false }
        set {
            var data = extra
            data.set(newValue, for: .isFavorite)
            extra = data
        }
    }
}
