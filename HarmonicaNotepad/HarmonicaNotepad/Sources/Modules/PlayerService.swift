//
//  PlayerService.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.05.2025.
//

import Combine
import MusicTheory

final class PlayerService {
    private let player = MidiNotePlayer()

    private var playbackTask: Task<Void, Never>?
    private var currentlyPlayingNote: MelodyNote?

    @Published private var playingNoteIndex: Int?
    var playingNoteIndexPublisher: AnyPublisher<Int?, Never> {
        $playingNoteIndex.eraseToAnyPublisher()
    }

    func playNote(_ note: MelodyNote, with tempo: Tempo) async {
        if let current = currentlyPlayingNote {
            player.stop(note: current.note)
        }

        currentlyPlayingNote = note
        player.play(note: note.note)

        let duration = tempo.duration(of: note.value)

        do {
            try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        } catch {
            player.stop(note: note.note)
            return
        }

        player.stop(note: note.note)

        await MainActor.run {
            playingNoteIndex = nil
        }

        currentlyPlayingNote = nil
    }

    func stopPlayingMeloday() {
        playbackTask?.cancel()
        didFinishPlayMelody()
    }

    func playMelody(_ melody: Melody, completion: @escaping () -> Void) {
        guard playbackTask == nil else {
            stopPlayingMeloday()
            completion()
            return
        }

        playbackTask = Task {
            var skippedServiceNotesCount: Int = 0
            for (index, note) in melody.notes.enumerated() {
                skippedServiceNotesCount += note.type == .newLine ? 1 : 0
                await MainActor.run { [skippedServiceNotesCount] in
                    playingNoteIndex = note.isServiceNote ? nil : (index - skippedServiceNotesCount)
                }

                switch note.type {
                    case .normal:
                        await playNote(note, with: melody.tempo)

                    case .silence, .newLine:
                        let duration = melody.duration(for: note)
                        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

                        await MainActor.run {
                            playingNoteIndex = nil
                        }
                }
            }
            await MainActor.run {
                didFinishPlayMelody()
                completion()
            }
        }
    }

    private func didFinishPlayMelody() {
        playbackTask = nil
        playingNoteIndex = nil
    }
}
