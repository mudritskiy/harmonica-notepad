//
//  SwiftDataService.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 29.06.2025.
//

import Foundation
import SwiftData

protocol SwiftDataServiceFileFactory {
//    func makeFile(for group: SwiftDataModelGroup) -> URL
    func makeFile(name: String?) -> URL
}

struct SwiftDataServiceFileFactoryImpl: SwiftDataServiceFileFactory {
    private let _filePrefix = "swift_data"
    private let _fileExtension = "sqlite"
    private let _mainBundleName = "main"

    func makeFile(name: String? = nil) -> URL {
        let name: String = name ?? _mainBundleName
        let fileName = "\(_filePrefix)_\(name).\(_fileExtension)"
        return URL.documentsDirectory.appending(path: fileName)
    }
}

enum SwiftDataServiceError: Error {
    case noModelRegistered
    case failedToRecreateStore(storeError: Error, recreationError: Error)
}


protocol SwiftDataCoreService {
    func container() -> ModelContainer
    func previewContainer() -> ModelContainer
}

final class SwiftDataCoreServiceImpl: SwiftDataCoreService {
    static let shared: SwiftDataCoreService = SwiftDataCoreServiceImpl()

    // MARK: - Dependencies
    private let _fileFactory: SwiftDataServiceFileFactory
    private let _fileEncryptor: FileEncryptor

    // MARK: - Properties
    private var _cachedContainer: ModelContainer?
    private var _cachedConfiguration: ModelConfiguration?
    private let _models: [any PersistentModel.Type] = [
        HarmonicaSong.self,
        FavoriteSong.self,
        SongsList.self,
        SongsListData.self
    ]

    // MARK: - Init
    private init(
        fileFactory: SwiftDataServiceFileFactory = SwiftDataServiceFileFactoryImpl(),
        fileEncryptor: FileEncryptor = FileEncryptorImpl()
    ) {
        _fileFactory = fileFactory
        _fileEncryptor = fileEncryptor
    }

    // MARK: - Service
    func container() -> ModelContainer {
        do {
            return try _container()
        } catch {
            fatalError("Coud not configure the container: \(error)")
        }
    }

    func previewContainer() -> ModelContainer {
        do {
            let schema = try _schema()
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return container
        } catch {
            fatalError("Could not configure preview container: \(error)")
        }
    }

    private func _container() throws(SwiftDataServiceError) -> ModelContainer {
        if let container = _cachedContainer {
            return container
        }

        let schema = try _schema()
        let url = _fileFactory.makeFile(name: nil)
        debugPrint(url.absoluteString)
//        _encryptFile(at: url)

        let configuration: ModelConfiguration
        if let cachedConfiguration = _cachedConfiguration {
            configuration = cachedConfiguration
        } else {
            configuration = ModelConfiguration(schema: schema, url: url, allowsSave: true)
            _cachedConfiguration = configuration
        }

        let newContainer: ModelContainer
        do {
            newContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch let storeError {
            do {
                _removeOldStoreFiles(at: url)
                newContainer = try ModelContainer(for: schema, configurations: [configuration])
            } catch let recreationError {
                throw SwiftDataServiceError.failedToRecreateStore(
                    storeError: storeError,
                    recreationError: recreationError
                )
            }
        }

        _cachedContainer = newContainer
        return newContainer
    }

    private func _schema() throws(SwiftDataServiceError) -> Schema {
        guard !_models.isEmpty else {
            throw SwiftDataServiceError.noModelRegistered
        }

        let schema = Schema(_models)
        return schema
    }

    private func _removeOldStoreFiles(at url: URL) {
        try? FileManager.default.removeItem(at: url)
        try? FileManager.default.removeItem(at: url.appendingPathExtension("shm"))
        try? FileManager.default.removeItem(at: url.appendingPathExtension("wal"))
    }

    private func _encryptFile(at url: URL) {
        Task { @MainActor in
            _fileEncryptor.encryptFile(with: url) { _ in
                // handle the result of success/failed file encryption
            }
        }
    }

    func resetContainer() {
        _cachedContainer = nil
        let customURL = _fileFactory.makeFile(name: nil)
        _removeOldStoreFiles(at: customURL)
    }
}
