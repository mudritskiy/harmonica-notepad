//
//  EventStream.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 25.03.2026.
//

import SwiftUI

final class EventStream<Event> {
    private var continuation: AsyncStream<Event>.Continuation?

    lazy var stream: AsyncStream<Event> = {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }()

    func send(_ event: Event) {
        continuation?.yield(event)
    }
}
