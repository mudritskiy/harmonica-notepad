//
//  SearchListView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.11.2025.
//

import SwiftData
import SwiftUI

struct SearchListView: View {
    @State private var searchText = ""

    var body: some View {
        SearchListContentView(searchText: searchText)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer,
                prompt: "Search harmonica songs"
            )
    }
}

struct SearchListContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.currentRouter) private var _router: (any AppRouter)?

    let searchText: String

    @Query
    var songs: [HarmonicaSong]

    // MARK: - Init
    init(searchText: String) {
        self.searchText = searchText

        let predicate = #Predicate<HarmonicaSong> { song in
            searchText.isEmpty ||
            song.title.localizedStandardContains(searchText) ||
            song.artist.localizedStandardContains(searchText)
        }

        _songs = Query(
            filter: predicate,
            sort: [SortDescriptor(\HarmonicaSong.title)],
            animation: .default
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(songs) { song in
                    Button {
                        _router?.navigate(to: SearchListRoute.showSong(song))
                    } label: {
                        Text(song.title)
                    }
                }
            }
        }
    }
}
