//
//  SongEditScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 22.06.2025.
//

import SwiftData
import SwiftUI

@Observable
final class SongEditScreenViewModel {
    enum Route: Hashable {
        case editMelody
    }

    private let _service: SwiftDataService
    private let _modelGroup: SwiftDataModelGroup = .song

    var song: HarmonicaSong
//    var title: String = ""

    var titleWidth: CGFloat {
        // Fallback placeholder text for measurement if empty
        let displayText = song.title.isEmpty ? "Title" : song.title
        let font = UIFont.systemFont(ofSize: 17)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (displayText as NSString).size(withAttributes: attributes)
        return size.width
    }

    @ObservationIgnored
    var melodyEditViewModel: MelodyEditScreenViewModel = MelodyEditScreenViewModel()

    init() {
        let service = SwiftDataServiceImpl.shared
        service.register(group: _modelGroup)
        self._service = service
        let songId = SongId("dba9df38-aa41-49d7-b3b7-311794d1fce0")
//        let songId = SongId(UUID().uuidString)
        song = HarmonicaSong(
            id: songId,
            title: "",
            melody: Melody(key: "")
//            melody: Melody(id: songId, key: "")
        )
    }

    func updateData() {
        song.melody = melodyEditViewModel.melody
//        song = HarmonicaSong(id: song.id, title: song.title, melody: melodyEditViewModel.melody)
    }

    func save() {
        Task {
            await _saveSongData(song)
        }
    }

    @MainActor
    private func _saveSongData(_ data: HarmonicaSong) async {
        let descriptor = _songDescriptor(by: data.id)
        guard let context = try? _service.context(for: _modelGroup) else { return }

        if let song = try? context.fetch(descriptor).first {
            song.title = data.title
        } else {
            context.insert(data)
        }
    }

    func fetchSong() {
        Task {
            guard let song = await _fetchSongData(by: song.id)
            else { return }
            await MainActor.run {
                self.song = song
            }
        }
    }

    private func _fetchSongData(by id: SongId) async -> HarmonicaSong? {
        let descriptor = _songDescriptor(by: id)
        guard let context = try? await _service.context(for: _modelGroup),
              let song = try? context.fetch(descriptor).first
        else { return nil }

        return song
    }

    private func _songDescriptor(by id: SongId) -> FetchDescriptor<HarmonicaSong> {
        var descriptor = FetchDescriptor<HarmonicaSong>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return descriptor
    }
}

final class SongDataService {
    private let _service: SwiftDataService
    private let _modelGroup: SwiftDataModelGroup = .song

    init() {
        let service = SwiftDataServiceImpl.shared
        service.register(group: _modelGroup)
        self._service = service
    }

    func saveSongData(_ data: HarmonicaSong) async {
        let descriptor = _songDescriptor(by: data.id)
        guard let context = try? await _service.context(for: _modelGroup) else { return }

        if let song = try? context.fetch(descriptor).first {
            song.title = data.title
        } else {
            context.insert(data)
        }
    }

    func fetchSongData(by id: SongId) async -> HarmonicaSong? {
        let descriptor = _songDescriptor(by: id)
        guard let context = try? await _service.context(for: _modelGroup),
              let song = try? context.fetch(descriptor).first
        else { return nil }
        return song
    }

    private func _songDescriptor(by id: SongId) -> FetchDescriptor<HarmonicaSong> {
        var descriptor = FetchDescriptor<HarmonicaSong>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return descriptor
    }
}

struct SongEditScreenView: View {
    @Bindable private var _viewModel: SongEditScreenViewModel
    @Environment(MainRouter.self) private var _router

    init(viewModel: SongEditScreenViewModel) {
        _viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            VStack(spacing: 4) {
                TextField("Title", text: $_viewModel.song.title)
//                TextEditor(text: $_viewModel.title)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
//                    .lineSpacing(8)
                    .textFieldStyle(.plain)
                Rectangle()
                    .frame(
                        width: _viewModel.titleWidth + 32, // add extra space
                        height: 0.5
                    )
                    .foregroundColor(.gray)
                    .animation(.easeInOut, value: _viewModel.titleWidth) // animate width change
                Text("Title")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            Button {
                _router.navigate(to: SongEditScreenViewModel.Route.editMelody)
            } label: {
                Text("Edit melody")
            }
            .padding(.top, 16)
            Button {
                _viewModel.save()
            } label: {
                Text("Save melody")
            }
            .padding(.top, 16)
            Button {
                _viewModel.fetchSong()
            } label: {
                Text("Load melody")
            }
            .padding(.top, 16)
            NotesPresentationView(notes: _viewModel.song.melody.notes, style: .numbers)
                .padding(.top, 16)
            Spacer()
        }
        .padding(.horizontal, 16)
        .onAppear {
            _viewModel.updateData()
        }
        .navigationDestination(for: SongEditScreenViewModel.Route.self) { route in
            switch route {
                case .editMelody:
                    MelodyEditScreenView(
                        viewModel: _viewModel.melodyEditViewModel
                    )
            }
        }
        .environment(_router)
    }
}

enum NotesPresentationStyle {
    case numbers
}

struct NotesPresentationView: View {
    private var _presentationStyle: NotesPresentationStyle = .numbers
    private var _notes: [MelodyNote]

    init(notes: [MelodyNote], style: NotesPresentationStyle) {
        _notes = notes
        _presentationStyle = style
    }

    var body: some View {
        switch _presentationStyle {
            case .numbers:
                NotesPresentationNumbersStyleView(
                    viewModel: NotesPresentationNumbersStyleViewModel(notes: _notes)
                )
        }
    }
}

@Observable
final class NotesPresentationNumbersStyleViewModel {
    let notes: [MelodyNote]
    let notesRows: [[MelodyNote]]

    private let _melodyService = MelodyService()

    init(notes: [MelodyNote]) {
        self.notes = notes
        notesRows = _melodyService.breakInRows(notes: notes)
    }
}

struct NotesPresentationNumbersStyleView: View {
    @Bindable var viewModel: NotesPresentationNumbersStyleViewModel

    var body: some View {
        ForEach(Array(viewModel.notesRows.enumerated()), id: \.offset) { rowIndex, notes in
            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(30)), count: 10),
                alignment: .leading,
                spacing: 2
            ) {
                ForEach(Array(notes.enumerated()), id: \.offset) { index, note in
                    let isPlaying = false //viewModel.isPlayingNote(rowIndex: rowIndex, at: index)
                    if case .silence = note.type {
                        Spacer()
                            .frame(width: 25, height: 25, alignment: .center)
                            .background(
                                MelodyNoteSimpleCellViewBackground(isActive: isPlaying)
                            )
                            .padding(2)
                    } else {
                        MelodyNoteSimpleCellView(
                            note: note.note,
                            isPlaying: isPlaying
                        )
                    }
                }
            }
            .padding(4)
        }
    }
}
