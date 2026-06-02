//
//  SongsListsView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.11.2025.
//

import SwiftData
import SwiftUI

enum SongsListsSortOption: String, CaseIterable, Identifiable {
    case name = "Name"
    case count = "Song Count"
    case lastAdded = "Last Added"

    var id: Self { self }
}

struct SongsListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SongsList.name) private var songsLists: [SongsList]

    @State private var sortOption: SongsListsSortOption = .name

    var sortedLists: [SongsList] {
        switch sortOption {
            case .name:
                return songsLists.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            case .count:
                return songsLists.sorted { $0.songsData.count > $1.songsData.count }
            case .lastAdded:
                return songsLists.sorted {
                    let date1 = $0.songsData.max(by: { $0.addedDate < $1.addedDate })?.addedDate ?? $0.createdDate
                    let date2 = $1.songsData.max(by: { $0.addedDate < $1.addedDate })?.addedDate ?? $1.createdDate
                    return date1 > date2
                }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedLists) { list in
                    NavigationLink(
                        destination: SongListDetailedView(songsListId: list.id)
                    ) {
                        SongsListRowView(songsList: list)
                    }
                    .listRowBackground(list.isDefault ? Color.blue.opacity(0.1) : Color.clear)
                }
            }
            .navigationTitle("My Harmonica Lists")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SongsListDetailsView()) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }

//                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(SongsListsSortOption.allCases) { option in
                            Button {
                                withAnimation {
                                    sortOption = option
                                }
                            } label: {
                                Label(option.rawValue, systemImage: sortIcon(for: option))
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }

        }
    }

    private func sortIcon(for option: SongsListsSortOption) -> String {
        sortOption == option ? "checkmark" : ""
    }
}
