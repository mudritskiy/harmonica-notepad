//
//  SongEditableProperties.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 23.11.2025.
//

final class SongEditableProperties: HarmonicaSongProperties {
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
