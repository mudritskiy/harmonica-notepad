//
//  SongScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 06.07.2025.
//

import SwiftData
import SwiftUI

enum SongScreenAssembly {
    static func makeViewModel(
        with song: HarmonicaSong?
    ) -> SongScreenViewModel {
        SongScreenViewModel(
            song: song,
            playerService: .shared,
            melodyService: MelodyServiceImpl(),
            listsService: SongsListsServiceImpl.shared
        )
    }
}

struct SongScreenView: View {
    // Identifiable wrapper for routes
    struct ModalRoute: Identifiable {
        let id = UUID()
        let route: SongScreenViewModel.Route
    }

    @Environment(\.currentRouter) private var _router: (any AppRouter)?
    @Environment(\.modelContext) private var _context
    @Environment(\.dismiss) private var dismiss

    // Local state for modal presentation
    @State private var _modalRoute: ModalRoute?
    @State private var _hasUnsavedChanges = false
    @State private var _isListSelectionPresented: Bool = false

    @State private var _viewModel: SongScreenViewModel

    private let _buttonEditTitlesSize: CGFloat = 20
    private let _buttonEditTitlesInsets: CGFloat = 8
    private var _titlesMinHeight: CGFloat { _buttonEditTitlesSize + _buttonEditTitlesSize }

    // MARK: - Init
    init(song: HarmonicaSong? = nil) {
        _viewModel = SongScreenAssembly.makeViewModel(with: song)
    }

    // MARK: - Render
    var body: some View {
            _screenView()
                .toolbar {
                    _toolbarContent()
                }
                .toolbar(.hidden, for: .tabBar)
                .navigationBarBackButtonHidden()
                .onFirstAppear {
                    _viewModel.context = _context
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
                .autoSizingBottomSheet(
                    isPresented: $_isListSelectionPresented,
                    props: _viewModel.listSelectionProps
                ) {
                    ListSelectionView(
                        service: _viewModel._listsService,
                        songId: _viewModel.song.id
                    )
                    .padding(.all, 16)
                }
                .task(id: _isListSelectionPresented) {
                    guard !_isListSelectionPresented else { return }
                    _viewModel.fetchLists()
                }
    }

    @ToolbarContentBuilder
    private func _toolbarContent() -> some ToolbarContent {
        SongToolbarContent(
            isApplyButtonVisible: _hasUnsavedChanges,
            onDismiss: {
                dismiss()
            },
            onListsTap: {
                _isListSelectionPresented = true
            },
            onSaveTap: {
                _viewModel.save() {
                    dismiss()
                }
            }
        )
    }

    @ViewBuilder
    private func _modalView(for route: SongScreenViewModel.Route) -> some View {
        switch route {
            case .editSong:
                SongEditScreenView(
                    viewModel: _viewModel.songEditScreenViewModel,
                    hasUnsavedChanges: $_hasUnsavedChanges
                )
        }
    }

    private func _screenView() -> some View {
        ZStack(alignment: .bottom) {
            _contentView()
                .padding(.bottom, 16)
            _bottomToolbar()
        }
        .padding(.horizontal, 16)
        .background(Theme.colors.background.primary.color)
    }

    private func _bottomToolbar() -> some View {
        SongBottomToolbarView(
            isPlaying: _viewModel.isPlayingMelody,
            onPlayTap: {
                _viewModel.onPlayTap()
            },
            onEditTap: {
                _router?.navigate(to: SongScreenRoute.editMelody(
                    _viewModel.melodyEditScreenViewModel
                ))
            }
        )
    }

    private func _contentView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            _songCardView()
            if _viewModel.isSongListVisible {
                _songListsView()
            }
            _melodyNotesView()
                .stretching(.vertical)
        }
    }

    private func _songCardView() -> some View {
        CardContainer(
            cornerRadius: 20,
            borderWidth: 1,
            backgroundColor: Theme.colors.background.secondary.color,
            borderColor: Theme.colors.background.secondary.color
        ) {
            VStack(alignment: .leading, spacing: 8) {
                _songHeaderCardView()
                    .shadow(
                        color: Theme.colors.background.shadow.color,
                        radius: 2,
                        x: 0,
                        y: 1
                    )
                _songSummarySection()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
        }
        .themeShadow()
    }

    private func _songHeaderCardView() -> some View {
        CardContainer(
            cornerRadius: 20,
            borderWidth: 0,
            backgroundColor: Theme.colors.background.accent.color,
            borderColor: Theme.colors.background.accent.color
        ) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: _viewModel.song.artist.isEmpty ? .center : .top, spacing: .zero) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(_viewModel.song.title)
                            .font(FontToken.title2.value)
                            .foregroundStyle(Theme.colors.text.contrastSecondary.color)
                        if !_viewModel.song.artist.isEmpty {
                            Text(_viewModel.song.artist)
                                .font(FontToken.headline.value)
                                .foregroundStyle(Theme.colors.text.contrastSecondary.color)
                        }
                    }
                    Spacer()
                    _buttonEditTitles()
                }
                .frame(minHeight: _titlesMinHeight)
                if !_viewModel.song.comments.isEmpty {
                    CustomDivider.horizontal(
                        color: Theme.colors.background.secondary,
                        lineWidth: 0.5
                    )
                    .padding(.trailing, 8)
                    Text(_viewModel.song.comments)
                        .font(FontToken.body2.value)
                        .foregroundStyle(Theme.colors.text.secondary.color)
                }
            }
            .stretching()
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
        }
    }

    private func _songSummarySection() -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 4)  {
                Image(systemName: "key")
                Text("Key \(_viewModel.song.melody.key.description)")
            }
            .frame(maxWidth: .infinity)
            HStack(spacing: 4)  {
                Image(systemName: "metronome")
                Text(
                    "\(String(format: "%d bpm", Int(_viewModel.song.melody.bpm)))"
                )
            }
            .frame(maxWidth: .infinity)
            HStack(spacing: 4)  {
                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                Text(_viewModel.songDuration)
            }
            .frame(maxWidth: .infinity)
            HStack(spacing: 4)  {
                Image(systemName: "music.note.list")
                Text("\(String(_viewModel.songCount)) notes")
            }
            .frame(maxWidth: .infinity)
        }
        .font(FontToken.caption.value)
        .foregroundStyle(Theme.colors.text.contrast.color)
    }

    private func _songListsView() -> some View {
        WrappedTextListView(
            items: _viewModel.listsWithSongWrappedItems,
            itemProps: _viewModel.listsWithSongProps,
            rowsCount: 3,
            minimumRowCount: 3,
            rowSpacing: 4,
            elementSpacing: 8
        )
        .stretching()
    }

    private func _buttonEditTitles() -> some View {
        Button {
            _modalRoute = ModalRoute(route: SongScreenViewModel.Route.editSong)
        } label: {
            Image(systemName: "square.and.pencil")
                .resizable()
                .foregroundStyle(Theme.colors.icon.secondary.color)
                .font(FontToken.body2.value)
                .frame(
                    width: _buttonEditTitlesSize,
                    height: _buttonEditTitlesSize,
                    alignment: .center
                )
                .padding(_buttonEditTitlesInsets)
        }
    }

    private func _melodyNotesView() -> some View {
        MelodyNotesPresentationView(
            props: MelodyNotesPresentationViewProps(
                melodyRows: _viewModel.melodyRows,
                playerEventStream: _viewModel.playerEventStream()
            ),
            cursorIndex: Binding.constant(nil)
        )
    }
}
