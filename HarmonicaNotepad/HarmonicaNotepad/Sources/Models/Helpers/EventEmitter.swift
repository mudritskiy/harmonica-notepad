//
//  EventEmitter.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 27.03.2026.
//

import SwiftUI

final class EventEmitter<Event> {
    private var _continuations: [UUID: AsyncStream<Event>.Continuation] = [:]

    func stream() -> AsyncStream<Event> {
        let id = UUID()

        return AsyncStream { continuation in
            _continuations[id] = continuation

            continuation.onTermination = { [weak self] _ in
                self?._continuations.removeValue(forKey: id)
            }
        }
    }

    func send(_ event: Event) {
        _continuations.values.forEach { $0.yield(event) }
    }

    func finish() {
        _continuations.values.forEach { $0.finish() }
        _continuations.removeAll()
    }
}
