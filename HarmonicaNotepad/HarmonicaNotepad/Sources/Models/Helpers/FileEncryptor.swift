//
//  FileEncryptor.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 29.06.2025.
//

import Foundation

typealias FileEncryptorCompletion = (Bool) -> Void

protocol FileEncryptor {
    func encryptFile(with url: URL, completion: FileEncryptorCompletion?)
}

final class FileEncryptorImpl: FileEncryptor {
    private var _timer: Timer?
    private var _retryCount = 0
    private let _maxRetries: Int = 3

    init() {}

    func encryptFile(with url: URL, completion: FileEncryptorCompletion?) {
        _retryCount = 0
        _startEncryptionAttempt(with: url, completion: completion)
    }

    private func _startEncryptionAttempt(with url: URL, completion: FileEncryptorCompletion?) {
        if _retryCount < _maxRetries {
            _encryptFileWithProtection(url: url) { [weak self] success in
                if success {
                    completion?(true)
                } else {
                    self?._retryCount += 1
                    self?._startRetryTimer(with: url, completion: completion)
                }
            }
        } else {
            completion?(false)
        }
    }

    private func _encryptFileWithProtection(url: URL, completion: FileEncryptorCompletion?) {
        do {
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.complete],
                ofItemAtPath: url.path
            )
            completion?(true)
        } catch {
            completion?(false)
        }
    }

    private func _startRetryTimer(with url: URL, completion: FileEncryptorCompletion?) {
        _timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?._startEncryptionAttempt(with: url, completion: completion)
        }
    }
}
