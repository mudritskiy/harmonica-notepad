//
//  SongListDetailedView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.11.2025.
//

import SwiftData
import SwiftUI

struct SongListDetailedView: View {
    @Environment(\.modelContext) private var modelContext
    let songsListId: SongsListId

    @Query var entries: [SongsListData]
    @State private var sortOption: SortOption = .addedDate

    enum SortOption: String, CaseIterable, Identifiable {
        case name = "Song Name", addedDate = "Added Date", artist = "Artist"
        var id: Self { self }
    }

    init(songsListId: SongsListId) {
        self.songsListId = songsListId
        let predicate = #Predicate<SongsListData> { $0.songsList?.id == songsListId }
        self._entries = Query(filter: predicate, sort: \.addedDate, order: .reverse)
    }

    private var songs: [HarmonicaSong] {
        let songIds = Set(entries.map(\.songId))
        let descriptor = FetchDescriptor<HarmonicaSong>(
            predicate: #Predicate { songIds.contains($0.id) }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private var sortedItems: [(song: HarmonicaSong, addedDate: Date)] {
        let map = Dictionary(grouping: entries, by: \.songId)
            .compactMapValues { $0.first } // one entry per song

        return songs.compactMap { song in
            guard let entry = map[song.id] else { return nil }
            return (song: song, addedDate: entry.addedDate)
        }
        .sorted { left, right in
            switch sortOption {
                case .name:
                    return left.song.title.localizedCaseInsensitiveCompare(right.song.title) == .orderedAscending
                case .artist:
                    return left.song.artist.localizedCaseInsensitiveCompare(right.song.artist) == .orderedAscending
                case .addedDate:
                    return left.addedDate > right.addedDate
            }
        }
    }

    var body: some View {
        List {
            ForEach(sortedItems, id: \.song.id) { item in
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.song.title)
                        .font(.headline)
                    HStack {
                        Text(item.song.artist)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(item.addedDate, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(entries.first?.songsList?.name ?? "Song List")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(SortOption.allCases) { option in
                        Button {
                            withAnimation { sortOption = option }
                        } label: {
                            Label(option.rawValue, systemImage: sortOption == option ? "checkmark" : "")
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
    }
}
