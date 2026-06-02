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
            .background(Theme.colors.background.primary.color)
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
        if songs.isEmpty {
            Theme.colors.background.primary.color
        } else {
            _content
//                .padding(.horizontal, 16)
        }
    }

    private var _content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(songs) { song in
                    Button {
                        _router?.navigate(to: SearchListRoute.showSong(song))
                    } label: {
                        SongListCardView(song: song)
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}

struct SongListCardView: View {
    let song: HarmonicaSong

    var body: some View {
        _songHeaderCardView(song: song)
//        _songCardView(song: song)
    }

    private func _songCardView(song: HarmonicaSong) -> some View {
        CardContainer(
            cornerRadius: 20,
            borderWidth: 1,
            backgroundColor: Theme.colors.background.secondary.color,
            borderColor: Theme.colors.background.secondary.color
        ) {
            VStack(alignment: .leading, spacing: 8) {
                _songHeaderCardView(song: song)
                    .shadow(
                        color: Theme.colors.background.shadow.color,
                        radius: 2,
                        x: 0,
                        y: 1
                    )
//                _songSummarySection()
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 8)
            }
        }
    }

    private func _songHeaderCardView(song: HarmonicaSong) -> some View {
        CardContainer(
            cornerRadius: 12,
            borderWidth: 0,
            backgroundColor: Theme.colors.background.accent.color,
            borderColor: Theme.colors.background.primaryTinted.color
        ) {
            VStack(alignment: .leading, spacing: 8) {
//                HStack(alignment: song.artist.isEmpty ? .center : .top, spacing: .zero) {
                HStack(alignment: .center, spacing: .zero) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(song.title)
                            .font(FontToken.body0.value)
                            .foregroundStyle(Theme.colors.text.contrastSecondary.color)
                            .multilineTextAlignment(.leading)
                        if !song.artist.isEmpty {
                            Text(song.artist)
                                .font(FontToken.body2.value)
                                .foregroundStyle(Theme.colors.text.contrastSecondary.color)
                        }
                    }
                    Spacer()
                    _buttonEditTitles()
                }
//                .frame(minHeight: _titlesMinHeight)
//                if !song.comments.isEmpty {
//                    CustomDivider.horizontal(
//                        color: Theme.colors.background.secondary,
//                        lineWidth: 0.5
//                    )
//                    .padding(.trailing, 8)
//                    Text(song.comments)
//                        .font(FontToken.body2.value)
//                        .foregroundStyle(Theme.colors.text.secondary.color)
//                }
            }
            .stretching()
            .padding(.leading, 8)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
        }
//        .themeShadow(.secondary)
//        .shadow(
//            color: Theme.colors.background.shadow.color,
//            radius: 2
//        )
        .shadow(
            color: Theme.colors.background.shadow.color,
            radius: 1,
            x: 1,
            y: 1
        )
    }

    private func _songSummarySection() -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 4)  {
                Image(systemName: "key")
//                Text("Key \(_viewModel.song.melody.key.description)")
                Text("Key C")
            }
//            .frame(maxWidth: .infinity)
//            HStack(spacing: 4)  {
//                Image(systemName: "metronome")
//                Text(
//                    "\(String(format: "%d bpm", Int(_viewModel.song.melody.bpm)))"
//                )
//            }
//            .frame(maxWidth: .infinity)
//            HStack(spacing: 4)  {
//                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
//                Text(_viewModel.songDuration)
//            }
//            .frame(maxWidth: .infinity)
//            HStack(spacing: 4)  {
//                Image(systemName: "music.note.list")
//                Text("\(String(_viewModel.songCount)) notes")
//            }
//            .frame(maxWidth: .infinity)
        }
        .font(FontToken.caption.value)
        .foregroundStyle(Theme.colors.text.contrast.color)
    }

    private func _buttonEditTitles() -> some View {
        Button {
//            _modalRoute = ModalRoute(route: SongScreenViewModel.Route.editSong)
        } label: {
            Image(systemName: "chevron.right")
                .foregroundStyle(Theme.colors.icon.secondary.color)
                .font(FontToken.body2.value)
                .padding(.horizontal, 8)
        }
    }
}
