//
//  PlayerService.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.05.2025.
//

import Combine
import MusicTheory
import SwiftUI

enum PlayerEvent {
    case play(Int?)
    case stop
}

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
    var playerEvents: EventEmitter<PlayerEvent> { get }
    var isPlayingMelody: Bool { get }
}

final class PlayerService: PlayerServiceState {
    static let shared = PlayerService()

    let playerEvents: EventEmitter<PlayerEvent>

    private let _player: MidiNotePlayer
    private var _playbackTask: Task<Void, Never>?
    private var _currentlyPlayingNote: MelodyNote?

    #warning("Should be removed all that staff ")
    @Published var isPlayingMelody: Bool = false {
        didSet {
            _isPlayingMelodyContinuation?.yield(isPlayingMelody)
        }
    }
    private var _isPlayingMelodyContinuation: AsyncStream<Bool>.Continuation?
    var isPlayingMelodyStream: AsyncStream<Bool> {
        AsyncStream { [weak self] continuation in
            self?._isPlayingMelodyContinuation = continuation
        }
    }

    // MARK: - Init
    init() {
        playerEvents = EventEmitter<PlayerEvent>()
        _player = MidiNotePlayer()
    }

    deinit {
        playerEvents.finish()
    }

    func playNote(_ note: MelodyNote, with tempo: Tempo) async {
        if let current = _currentlyPlayingNote {
            _player.stop(note: current.note)
        }

        _currentlyPlayingNote = note
        _player.play(note: note.note)

        let duration = tempo.duration(of: note.value)

        do {
            try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
        } catch {
            _player.stop(note: note.note)
            return
        }

        _player.stop(note: note.note)
        _currentlyPlayingNote = nil
    }

    func stopPlayingMelody() {
        _playbackTask?.cancel()
        _playbackTask = nil
        Task {
            await _didFinishPlayMelody()
        }
    }

    func playMelody(_ notes: [MelodyNote], with tempo: Tempo) {
        guard _playbackTask == nil else {
            stopPlayingMelody()
            return
        }

        isPlayingMelody = true

        _playbackTask = Task {
            for (index, note) in notes.enumerated() {
                guard !Task.isCancelled else { return }
                await _notifyPlayingNote(with: index)

                switch note.type {
                    case .normal:
                        await playNote(note, with: tempo)

                    case .silence, .newLine:
                        let duration = tempo.duration(of: note.value)
                        try? await Task.sleep(for: .seconds(duration))
                }
            }

            guard !Task.isCancelled else { return }
            await _didFinishPlayMelody()
        }
    }

    @MainActor
    private func _notifyPlayingNote(with index: Int?) {
        playerEvents.send(PlayerEvent.play(index))
    }

    @MainActor
    private func _didFinishPlayMelody() {
        playerEvents.send(PlayerEvent.stop)
        isPlayingMelody = false
    }
}
