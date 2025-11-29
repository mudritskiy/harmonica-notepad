//
//  SongListView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 05.07.2025.
//

import SwiftData
import SwiftUI

@Observable
final class SongListViewModel {
    enum Route: Hashable {
        case showSong(HarmonicaSong)
    }

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
        List {
            ForEach(_viewModel.songs) { song in
                Button {
                    _router.navigate(to: SongListViewModel.Route.showSong(song))
                } label: {
                    Text(song.title)
                }
            }
            .onDelete { offsets in
                _viewModel.delete(at: offsets)
            }
        }
        .onAppear {
            _viewModel.modelContext = _context
            _viewModel.fetchSongs()
        }
        .navigationDestination(for: SongListViewModel.Route.self) { route in
            switch route {
                case .showSong(let song):
                    SongScreenContentView(initialSong: song)
//                    SongScreenView(
//                        viewModel: SongScreenViewModel(song: song)
//                    )
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    let newSong: HarmonicaSong = .new()
                    _router.navigate(to: SongListViewModel.Route.showSong(newSong))
                } label: {
                    Text("Add")
                }
            }

        }
        .environment(_router)
    }
}
