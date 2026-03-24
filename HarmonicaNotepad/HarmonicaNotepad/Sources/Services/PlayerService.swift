//
//  PlayerService.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.05.2025.
//

import Combine
import MusicTheory
import SwiftUI

private struct PlayerServiceKey: EnvironmentKey {
    static let defaultValue = PlayerService.shared
}

extension EnvironmentValues {
    var playerService: PlayerService {
        get { self[PlayerServiceKey.self] }
        set { self[PlayerServiceKey.self] = newValue }
    }
}

protocol PlayerServiceState {
    var isPlayingMelody: Bool { get }
    var isPlayingMelodyPublisher: AnyPublisher<Bool, Never> { get }
}

final class PlayerService: PlayerServiceState {
    static let shared = PlayerService()

    @Published var isPlayingMelody: Bool = false {
        didSet {
            _isPlayingMelodyContinuation?.yield(isPlayingMelody)
        }
    }

    var isPlayingMelodyPublisher: AnyPublisher<Bool, Never> {
        $isPlayingMelody.eraseToAnyPublisher()
    }

    private var _isPlayingMelodyContinuation: AsyncStream<Bool>.Continuation?
    var isPlayingMelodyStream: AsyncStream<Bool> {
        AsyncStream { [weak self] continuation in
            self?._isPlayingMelodyContinuation = continuation
        }
    }

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

    func stopPlayingMelody() {
        playbackTask?.cancel()
        didFinishPlayMelody()
    }

    func playMelody(_ notes: [MelodyNote], with tempo: Tempo) {
        guard playbackTask == nil else {
            stopPlayingMelody()
            return
        }

        isPlayingMelody = true

        playbackTask = Task {
            var skippedServiceNotesCount: Int = 0
            for (index, note) in notes.enumerated() {
                skippedServiceNotesCount += note.type == .newLine ? 1 : 0
                await MainActor.run { [skippedServiceNotesCount] in
                    playingNoteIndex = note.isServiceNote ? nil : (index - skippedServiceNotesCount)
                }

                switch note.type {
                    case .normal:
                        await playNote(note, with: tempo)

                    case .silence, .newLine:
                        let duration = tempo.duration(of: note.value)
                        try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))

                        await MainActor.run {
                            playingNoteIndex = nil
                        }
                }
            }
            await MainActor.run {
                didFinishPlayMelody()
            }
        }
    }

    private func didFinishPlayMelody() {
        playbackTask = nil
        playingNoteIndex = nil
        isPlayingMelody = false
    }
}
