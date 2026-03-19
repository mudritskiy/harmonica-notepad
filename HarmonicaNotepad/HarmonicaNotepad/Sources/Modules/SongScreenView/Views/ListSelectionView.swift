//
//  ListSelectionView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 19.03.2026.
//

import SwiftData
import SwiftUI

struct ListSelectionView: View {
    @Environment(\.modelContext) private var modelContext

    let service: SongsListsService
    let songId: SongId

    private let _selectedListsProps = WrappedTextListItemViewProps(
        font: .body1,
        color: Theme.colors.text.highlight,
        backgroundColor: Theme.colors.background.highlight,
        insets: EdgeInsets(
            top: 8,
            leading: 12,
            bottom: 8,
            trailing: 12
        )
    )

    @Query
    private var listsWithSong: [SongsList]

    @Query
    private var listsWithoutSong: [SongsList]

    // MARK: - Init
    init(
        service: SongsListsService,
        songId: SongId
    ) {
        self.service = service
        self.songId = songId

        let containsPredicate = #Predicate<SongsList> { list in
            list.songsData.contains { $0.songId == songId }
        }

        let notContainsPredicate = #Predicate<SongsList> { list in
            !list.songsData.contains { $0.songId == songId }
        }

        _listsWithSong = Query(filter: containsPredicate, sort: \SongsList.name)
        _listsWithoutSong = Query(filter: notContainsPredicate, sort: \SongsList.name)
    }

    // MARK: - Render
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !listsWithSong.isEmpty {
                _selectedLists()
                Divider()
            }
            _availableLists()

        }
        .background(Theme.colors.background.primary.color)
        .animation(.linear, value: listsWithSong.count)
    }

    private func _selectedLists() -> some View {
        WrappedTextListView(
            items: listsWithSong.map { list in
                WrappedTextListView.Item(
                    text: list.name,
                    action: {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                            service.removeSong(songId, from: list, in: modelContext)
                        }
                    }
                )
            },
            itemProps: _selectedListsProps
        )
    }

    private func _availableLists() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(listsWithoutSong) { list in
                HStack(alignment: .center, spacing: .zero) {
                    ChipsView(
                        props: ChipsProps(
                            title: list.name,
                            count: list.songsData.count
                        ) {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                                service.add(songId, to: list.id, in: modelContext)
                            }
                        }
                    )
                    Spacer()
                }
            }
        }
    }
}
