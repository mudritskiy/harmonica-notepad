//
//  SongEditScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 22.06.2025.
//

import MusicTheory
import SwiftData
import SwiftUI

@Observable
final class SongEditScreenViewModel {
    enum Route: Hashable {
        case editMelody
    }

    var modelContext: ModelContext? = nil

    var songId: SongId
    var title: String
    var melody: Melody

    var titleWidth: CGFloat {
        let displayText = title.isEmpty ? "Title" : title
        let font = UIFont.systemFont(ofSize: 17)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (displayText as NSString).size(withAttributes: attributes)
        return size.width
    }

    func isMelodyAvailable() -> Bool {
        !melody.notes.isEmpty
    }

    @ObservationIgnored
    lazy var melodyEditViewModel: MelodyEditScreenViewModel = {
        MelodyEditScreenViewModel(melody: melody, onApplyTap: { [weak self] in
            guard let self else { return }
            melody = Melody(
                key: melodyEditViewModel.key,
                tempo: melodyEditViewModel.tempo,
                notes: melodyEditViewModel.notes
            )
        })
    }()

    init(song: HarmonicaSong? = nil) {
        if let song = song {
            self.songId = song.id
            self.title = song.title
            self.melody = song.melody.value
        } else {
            self.songId = SongId(UUID().uuidString)
            self.title = ""
            self.melody = Melody()
        }
    }

    func save() {
        guard let container = modelContext?.container else { return }
        Task.detached(priority: .background) {
            let song = HarmonicaSong(
                id: self.songId,
                title: self.title,
                melody: MelodyWrapper(self.melody)
            )
            let actor = SongService(modelContainer: container)
            await actor.save(song)
        }
    }
}

@ModelActor
actor SongService {
    func save(_ data: HarmonicaSong) async {
        modelContext.insert(data)
        // TODO: case oparation failed
        try? modelContext.save()
    }

    func fetch(by id: SongId) async -> HarmonicaSong? {
        let descriptor = _songDescriptor(by: id)
        guard let song = try? modelContext.fetch(descriptor).first else { return nil }
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
    @Environment(\.modelContext) private var _context

    init(viewModel: SongEditScreenViewModel) {
        _viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .center, spacing: .zero) {
            VStack(spacing: 4) {
                TextField("Title", text: $_viewModel.title)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .textFieldStyle(.plain)
                Rectangle()
                    .frame(
                        width: _viewModel.titleWidth + 32,
                        height: 0.5
                    )
                    .foregroundColor(.gray)
                    .animation(.easeInOut, value: _viewModel.titleWidth)
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
            NotesPresentationView(
                notes: _viewModel.isMelodyAvailable() ? _viewModel.melody.notes : [],
                style: .numbers
            )
                .padding(.top, 16)
            Spacer()
        }
        .padding(.horizontal, 16)
        .onFirstAppear {
            _viewModel.modelContext = _context
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
