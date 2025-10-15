//
//  SongScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 06.07.2025.
//

import SwiftUI

@Observable
final class SongScreenViewModel {
    enum Route: Hashable {
        case editSong
        case editMelody
    }

    var song: HarmonicaSong

    init(song: HarmonicaSong) {
        self.song = song
    }
}

struct SongScreenView: View {
    private var _viewModel: SongScreenViewModel
    @Environment(MainRouter.self) private var _router

    init(viewModel: SongScreenViewModel) {
        _viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
            .padding(.vertical, 16)
            Text(_viewModel.song.comments)
                .font(.caption)
                .fontWeight(.light)
            if let tags = _viewModel.song.tags {
                HStack(alignment: .center, spacing: 8) {
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
                    Spacer()
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Button {
                            _router.navigate(to: SongScreenViewModel.Route.editSong)
                        } label: {
                            ButttonEditContentViewV2()
                        }
                        .padding(.trailing, 16)
                    }
               }
                .padding(.vertical, 16)
            }
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.vertical, 16)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text("Melody")
                        .font(.title2)
                        .fontWeight(.regular)
                    Spacer()
                    Button {
                        _router.navigate(to: SongScreenViewModel.Route.editSong)
                    } label: {
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
                    Button {
                        _router.navigate(to: SongScreenViewModel.Route.editSong)
                    } label: {
                        ButttonEditContentViewV2()
                    }
                    .padding(.trailing, 16)
                        .padding(.leading, 16)
                }

                HStack(spacing: 0) {
                    HStack(spacing: 0)  {
                        Image(systemName: "key")
                        Text("Key \(_viewModel.song.melody.key.description)")
                            .padding(.leading, 4)
                    }
                    HStack(spacing: 0)  {
                        Image(systemName: "metronome")
                        Text(
                            "\(TempoStyle.tempo(for: Int(_viewModel.song.melody.bpm)).presentation) (\(String(format: "%d bpm", Int(_viewModel.song.melody.tempo.bpm))))"
                        )
                        .padding(.leading, 4)
                    }
                    .padding(.leading, 8)
                    Spacer()
                }
                .font(.caption)
                .fontWeight(.thin)
                .padding(.top, 16)

                ScrollView {
                    NotesPresentationView(
                        notes: _viewModel.song.melody.notes,
                        style: .numbers
                    )
                }
                .padding(.top, 16)
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
            Spacer()
        }
        .padding(16)
        .navigationDestination(for: SongScreenViewModel.Route.self) { route in
            switch route {
                case .editSong:
                    SongEditScreenView(
                        viewModel: SongEditScreenViewModel(song: _viewModel.song)
                    )
                case .editMelody:
                    EmptyView()
            }
        }
    }
}

struct ButttonEditContentView: View {
    var body: some View {
        Image(systemName: "square.and.pencil")
            .resizable()
            .foregroundStyle(.white)
            .frame(width: 16, height: 16, alignment: .center)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray.opacity(0.75))
                    .frame(width: 32, height: 32, alignment: .center)
                    .padding(.trailing, 2)
                    .padding(.top, 2)
            }
    }
}

struct ButttonEditContentViewV2: View {
    var body: some View {
        Image(systemName: "square.and.pencil")
            .resizable()
            .foregroundStyle(.black)
            .font(.callout)
            .fontWeight(.light)
            .frame(width: 20, height: 20, alignment: .center)
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
