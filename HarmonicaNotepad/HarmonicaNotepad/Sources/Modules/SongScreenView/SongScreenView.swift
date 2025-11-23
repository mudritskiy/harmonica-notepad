//
//  SongScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 06.07.2025.
//

import SwiftUI

struct SongScreenView: View {
    // Identifiable wrapper for routes
    struct ModalRoute: Identifiable {
        let id = UUID()
        let route: SongScreenViewModel.Route
    }

    @Environment(MainRouter.self) private var _router
    @Environment(\.modelContext) private var _context
    @Environment(\.dismiss) private var dismiss

    // Local state for modal presentation
    @State private var _modalRoute: ModalRoute?
    @State private var _hasUnsavedChanges = false

    private var _viewModel: SongScreenViewModel

    // MARK: - Init
    init(viewModel: SongScreenViewModel) {
        _viewModel = viewModel
    }

    // MARK: - Render
    var body: some View {
        _contentView()
            .padding(16)
            .navigationDestination(for: SongScreenViewModel.Route.self) { route in
                _modalView(for: route)
            }
            .toolbar {
                _toolbarContent()
            }
            .navigationBarBackButtonHidden()
            .onFirstAppear {
                _viewModel.modelContext = _context
                _hasUnsavedChanges = false
            }
            .sheet(item: $_modalRoute) { modalRoute in
                NavigationStack {
                    _modalView(for: modalRoute.route)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.thinMaterial)
                .interactiveDismissDisabled(_hasUnsavedChanges)
            }
    }

    @ToolbarContentBuilder
    private func _toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                _viewModel.save()
                dismiss()
            } label: {
                Image(systemName: "checkmark")
            }
        }
    }

    @ViewBuilder
    private func _modalView(for route: SongScreenViewModel.Route) -> some View {
        switch route {
            case .editSong:
                SongEditScreenView(
                    viewModel: _viewModel.songEditScreenViewModel,
                    hasUnsavedChanges: $_hasUnsavedChanges
                )
            case .editMelody:
                MelodyEditScreenView(
                    viewModel: _viewModel.melodyEditScreenViewModel
                )
        }
    }

    private func _contentView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            _songHeaderView()
            _songSummarySection()
                .padding(.vertical, 16)
            Text(_viewModel.song.comments)
                .font(.caption)
                .fontWeight(.light)
            _songFooterView()
                .padding(.vertical, 16)
            _deviderView()
            _melodyView()
            Spacer()
        }
    }

    private func _songHeaderView() -> some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(_viewModel.song.title)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(_viewModel.song.artist)
                    .font(.subheadline)
                    .fontWeight(.thin)
                    .padding(.top, 4)
            }
            Spacer()
            Group {
                Image(systemName: "heart")
                Image(systemName: "square.and.arrow.up")
            }
            .padding(.all, 16)
        }
    }

    private func _songSummarySection() -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 0)  {
                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                Text("3 min")
                    .padding(.leading, 4)
            }
            HStack(spacing: 0)  {
                Image(systemName: "music.note.list")
                Text("12 notes")
                    .padding(.leading, 4)
            }
            .padding(.leading, 8)
            HStack(spacing: 0)  {
                Image(systemName: "chevron.up.2")
                Text("easy")
                    .padding(.leading, 4)
            }
            .padding(.leading, 8)
            Spacer()
        }
        .font(.caption)
        .fontWeight(.thin)
    }

    private func _songFooterView() -> some View {
        HStack(alignment: .center, spacing: 8) {
            if let tags = _viewModel.song.tags {
                ForEach(tags) { tag in
                    Text(tag.value)
                        .padding(.horizontal, 8)
                        .font(.caption2)
                        .fontWeight(.light)
                        .fontDesign(.rounded)
                        .foregroundStyle(.black.opacity(0.7))
                        .frame(height: 20)
                        .background {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.gray.opacity(0.1))
                        }
                }
            }
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Button {
                    _modalRoute = ModalRoute(route: SongScreenViewModel.Route.editSong)
//                    _router.navigate(to: SongScreenViewModel.Route.editSong)
                } label: {
                    ButttonEditContentViewV2()
                }
                .padding(.trailing, 16)
            }
        }
    }

    private func _deviderView() -> some View {
        Rectangle()
            .frame(height: 0.5)
            .foregroundColor(.gray.opacity(0.5))
            .padding(.vertical, 16)
    }

    private func _melodyView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            _melodyHeaderView()
            _melodySummaryView()
                .padding(.top, 16)
            _melodyNotesView()
                .padding(.top, 16)
            _expandButtonSectionView()
        }
    }

    private func _melodyHeaderView() -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text("Melody")
                .font(.title2)
                .fontWeight(.regular)
                .stretching()
            _playButton()
            _showEditMelodyButton()
                .padding(.trailing, 16)
                .padding(.leading, 16)
        }
    }

    private func _playButton() -> some View {
        Button {
//            _router.navigate(to: SongScreenViewModel.Route.editSong)
            _viewModel.onPlayTap()
        } label: {
            _playButtonContentView()
        }
    }

    private func _showEditMelodyButton() -> some View {
        return Button {
            _router.navigate(to: SongScreenViewModel.Route.editMelody)
        } label: {
            ButttonEditContentViewV2()
        }
    }

    private func _playButtonContentView() -> some View {
        HStack(spacing: 0) {
            Image(systemName: "play")
            Text("Play")
                .padding(.leading, 4)
        }
        .padding(8)
        .font(.caption)
        .fontWeight(.light)
        .foregroundStyle(.black)
        .background {
            RoundedRectangle(cornerRadius: 4)
                .stroke(.gray.opacity(0.5), lineWidth: 0.5)
        }
    }

    private func _melodySummaryView() -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 0)  {
                Image(systemName: "key")
                Text("Key \(_viewModel.song.melody.key.description)")
                    .padding(.leading, 4)
            }
            HStack(spacing: 0)  {
                Image(systemName: "metronome")
                Text(
                    "\(TempoStyle.tempo(for: Int(_viewModel.song.melody.bpm)).presentation) (\(String(format: "%d bpm", Int(_viewModel.song.melody.bpm))))"
                )
                .padding(.leading, 4)
            }
            .padding(.leading, 8)
            Spacer()
        }
        .font(.caption)
        .fontWeight(.thin)
    }

    private func _melodyNotesView() -> some View {
        ScrollView {
            NotesPresentationView(
                notes: _viewModel.notes,
                style: .numbers
            )
        }
    }

    private func _expandButtonSectionView() -> some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "text.magnifyingglass")
                    .resizable()
                    .frame(width: 16, height: 16, alignment: .center)
                Text("expand".uppercased())
                    .padding(.leading, 8)
            }
            .foregroundStyle(.black)
            .fontWeight(.light)
            .font(.caption)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(style: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundColor(.gray)
            )
            Spacer()
        }
    }
}


#Preview {
    let preview = Preview()
    let appNavigation = AppNavigationModel()
    let song = preview.sampleSong(
        hasArtist: true,
        hasComments: true,
        hasTags: true,
        hasNotes: true
    )
    SongScreenView(
        viewModel: SongScreenViewModel(song: song)
    )
    .modelContainer(preview.container)
    .environment(appNavigation.mainRouter)
}
