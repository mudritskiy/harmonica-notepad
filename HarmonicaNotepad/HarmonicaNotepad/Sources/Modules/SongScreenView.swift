//
//  SongScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 06.07.2025.
//

import SwiftUI

@Observable
final class SongScreenViewModel {
    var song: HarmonicaSong

    init(song: HarmonicaSong) {
        self.song = song
    }
}

struct SongScreenView: View {
    private var _viewModel: SongScreenViewModel

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
                    Image(systemName: "metronome")
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
                            .frame(height: 20)
                            .background {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.gray.opacity(0.1))
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 4)
//                                            .stroke(.gray.opacity(0.1), lineWidth: 1)
////                                            .padding(1)
//                                    )
                            }
                    }
                }
                .padding(.vertical, 16)
            }
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.vertical, 16)
            NotesPresentationView(
                notes: _viewModel.song.melody.notes,
                style: .numbers
            )
            Spacer()
        }
        .padding(16)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {

                } label: {
                    HStack(alignment: .center, spacing: 0) {
                        Image(systemName: "heart")
                        Text("Back")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack(alignment: .center, spacing: 0) {
                    Button {

                    } label: {
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "square.and.pencil")
                            Text("Edit")
                        }
                    }
                }
            }
        }

    }
}

#Preview {
    let preview = Preview()
    let song = preview.sampleSong()
    SongScreenView(
        viewModel: SongScreenViewModel(song: song)
    )
}
