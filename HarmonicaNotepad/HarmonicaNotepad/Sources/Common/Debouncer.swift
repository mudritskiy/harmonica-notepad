//
//  Debouncer.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.03.2026.
//

import Foundation

// TODO: - Not used?
final class Debouncer {
    private let _delay: TimeInterval
    private var _timer: Timer?
    private var _action: (() -> Void)?

    public init(delay: TimeInterval) {
        _delay = delay
    }

    // MARK: - Dealloc
    deinit {
        invalidate()
    }

    public func run(repeats: Bool = false, _ action: @escaping () -> Void) {
        _action = action
        _timer?.invalidate()

        _timer = Timer.scheduledTimer(
            withTimeInterval: _delay,
            repeats: repeats
        ) { [weak self] timer in
            guard let self, timer.isValid else { return }

            self._action?()

            // If not repeating → clear after first fire
            if !repeats {
                self._action = nil
            }
        }
    }

    public func invalidate() {
        _timer?.invalidate()
        _action = nil
    }
}
