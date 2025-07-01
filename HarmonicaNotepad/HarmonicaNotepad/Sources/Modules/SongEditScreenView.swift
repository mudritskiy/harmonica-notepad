//
//  SongEditScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 22.06.2025.
//

import SwiftUI

@Observable
final class SongEditScreenViewModel {
    enum Route: Hashable {
        case editMelody
    }

//    @ObservationIgnored
    var song: HarmonicaSong = HarmonicaSong(title: "", melody: Melody(key: ""))
    var title: String = ""

    var titleWidth: CGFloat {
        // Fallback placeholder text for measurement if empty
        let displayText = title.isEmpty ? "Title" : title
        let font = UIFont.systemFont(ofSize: 17)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (displayText as NSString).size(withAttributes: attributes)
        return size.width
    }

    @ObservationIgnored
    var melodyEditViewModel: MelodyEditScreenViewModel = MelodyEditScreenViewModel()

    func updateData() {
        song = HarmonicaSong(title: title, melody: melodyEditViewModel.melody)
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
                TextField("Title", text: $_viewModel.title)
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

import SwiftData

typealias SongId = Identified<HarmonicaSong>

struct HarmonicaSong {
    let id: SongId
    let title: String
    let melody: Melody
}

@Model
final class HarmonicaSongDataModel {
    @Attribute(.unique) var id: SongId.RawValue
    var title: String

    init(id: SongId, title: String) {
        self.id = id
        self.title = title
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
