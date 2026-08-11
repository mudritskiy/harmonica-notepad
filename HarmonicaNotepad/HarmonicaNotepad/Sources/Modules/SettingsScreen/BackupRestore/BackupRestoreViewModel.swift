import Foundation
import SwiftData
import Observation

@Observable
final class BackupRestoreViewModel {
    var modelContext: ModelContext?
    var exportFileURL: URL?
    var showAlert = false
    var onRestoreCompleted: (() -> Void)?
    private(set) var alertInfo: AlertInfo = .empty()

    private var _pendingRestoreData: Data?
    private let _backupService: BackupService

    init(backupService: BackupService = BackupServiceImpl()) {
        _backupService = backupService
    }

    func refreshExportArtifacts() {
        guard let context = modelContext else { return }
        do {
            let payload = try _backupService.exportPayload(from: context)
            let data = try _backupService.encode(payload)
            exportFileURL = try _writeTempFile(data: data)
        } catch {
            _showError(_message(for: error))
        }
    }

    func prepareRestore(from url: URL) {
        let didStartAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }
        do {
            let data = try Data(contentsOf: url)
            _ = try _backupService.decode(data)
            _pendingRestoreData = data
            alertInfo = AlertInfo(
                title: "Replace all songs and lists with this backup?",
                message: "This can't be undone.",
                buttons: [
                    AlertButton("Cancel", role: .cancel) { self.showAlert = false },
                    AlertButton("Replace Everything", role: .destructive) {
                        self.showAlert = false
                        self._confirmRestore()
                    }
                ]
            )
            showAlert = true
        } catch {
            _showError(_message(for: error))
        }
    }

    func reportFileOperationFailure(_ error: Error) {
        if let cocoaError = error as? CocoaError, cocoaError.code == .userCancelled {
            return
        }
        _showError(_message(for: error))
    }

    private func _confirmRestore() {
        guard let context = modelContext, let data = _pendingRestoreData else { return }
        do {
            let payload = try _backupService.decode(data)
            try _backupService.restore(payload, into: context)
            _pendingRestoreData = nil
            refreshExportArtifacts()
            onRestoreCompleted?()
        } catch {
            let message = _message(for: error)
            DispatchQueue.main.async {
                self._showError(message)
            }
        }
    }

    private func _writeTempFile(data: Data) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("harmonica-backup")
            .appendingPathExtension("json")
        try data.write(to: url, options: .atomic)
        return url
    }

    private func _showError(_ message: String) {
        alertInfo = AlertInfo(
            title: "Backup Error",
            message: message,
            buttons: [AlertButton("OK") { self.showAlert = false }]
        )
        showAlert = true
    }

    private func _message(for error: Error) -> String {
        (error as? BackupError)?.errorDescription ?? error.localizedDescription
    }
}
