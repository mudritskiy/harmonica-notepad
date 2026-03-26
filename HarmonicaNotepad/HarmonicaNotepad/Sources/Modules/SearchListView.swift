//
//  SearchListView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.11.2025.
//

import SwiftData
import SwiftUI

struct SearchListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(MainRouter.self) private var _router

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            SearchListContentView(searchText: searchText)
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer,
                    prompt: "Search harmonica songs"
                )
        }
        .navigationTitle("Search")
    }
}

struct SearchListContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(MainRouter.self) private var _router
    let searchText: String

    @Query
    var songs: [HarmonicaSong]

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
//            order: .forward
            animation: .default
        )
    }

    var body: some View {
        List(songs) { song in
            Button {
                _router.navigate(to: SongListRoute.showSong(song))
            } label: {
                Text(song.title)
            }
        }
        .environment(_router)
    }
}
