//
//  SongListView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 05.07.2025.
//

import SwiftData
import SwiftUI

enum SongListRoute: Hashable, Equatable {
    case showSong(HarmonicaSong)
    case settings
}

@Observable
final class SongListViewModel {
    var modelContext: ModelContext? = nil
    var songs: [HarmonicaSong] = []

    func fetchSongs() {
        let descriptor = _songDescriptor()
        guard let songs = try? modelContext?.fetch(descriptor) else { return }
        self.songs = songs
    }

    func delete(at offsets: IndexSet) {
        guard let offset = offsets.first else { return }
        let song = songs.remove(at: offset)
        modelContext?.delete(song)
        // TODO: Oparation faild
        try? modelContext?.save()
    }

    private func _songDescriptor() -> FetchDescriptor<HarmonicaSong> {
        FetchDescriptor<HarmonicaSong>()
    }
}

struct SongListView: View {
    @Bindable private var _viewModel: SongListViewModel
    @Environment(MainRouter.self) private var _router
    @Environment(\.modelContext) private var _context

    init(viewModel: SongListViewModel) {
        _viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(_viewModel.songs) { song in
                    Button {
                        _router.navigate(to: SongListRoute.showSong(song))
                    } label: {
                        CardContainer(
                            backgroundColor: Theme.colors.background.highlight.color,
                            borderColor: Theme.colors.background.highlight.color
                        ) {
                            HStack(alignment: .center, spacing: .zero) {
                                Text(song.title)
                                    .font(FontToken.body1.value)
                                    .foregroundStyle(Theme.colors.text.highlight.color)
                                Spacer()
                            }
                            .padding(.all, 16)
                        }
                    }
                }
                //            .onDelete { offsets in
                //                _viewModel.delete(at: offsets)
                //            }
            }
            .padding(.horizontal, 16)
        }
        .onAppear {
            _viewModel.modelContext = _context
            _viewModel.fetchSongs()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    _router.navigate(to: SongListRoute.settings)
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let newSong: HarmonicaSong = .new()
                    _router.navigate(to: SongListRoute.showSong(newSong))
                } label: {
                    Text("Add")
                }
            }

        }
        .environment(_router)
    }
}
