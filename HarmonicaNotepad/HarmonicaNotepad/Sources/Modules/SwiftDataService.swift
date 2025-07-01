//
//  SwiftDataService.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 29.06.2025.
//

import Foundation
import SwiftData

protocol SwiftDataServiceFileFactory {
    func makeFile(for group: SwiftDataModelGroup) -> URL
}

struct SwiftDataServiceFileFactoryImpl: SwiftDataServiceFileFactory {
    let filePrefix = "swift_data"
    let fileExtension = "sqlite"

    func makeFile(for group: SwiftDataModelGroup) -> URL {
        let fileFullName = "\(filePrefix)_\(group.rawValue).\(fileExtension)"
        return URL.documentsDirectory.appending(path: fileFullName)
    }
}

enum SwiftDataServiceError: Error {
    case noModelRegistered
    case failedToRecreateStore(storeError: Error, recreationError: Error)
}

@available(iOS 17, *)
protocol SwiftDataService {
    static var shared: SwiftDataService { get }

    func register(group: SwiftDataModelGroup)
    func container(for group: SwiftDataModelGroup) throws -> ModelContainer
    func resetContainer(for group: SwiftDataModelGroup)
    func resetAllContainers()

    @MainActor
    func context(for group: SwiftDataModelGroup) throws(SwiftDataServiceError) -> ModelContext
}

@available(iOS 17, *)
class SwiftDataServiceImpl: SwiftDataService {
    static let shared: SwiftDataService = SwiftDataServiceImpl()

    // MARK: - Dependencies
    private let _modelFactory: SwiftDataServiceModelFactory
    private let _fileFactory: SwiftDataServiceFileFactory
    private let _fileEncryptor: FileEncryptor

    // MARK: - Properties
    private var modelGroups: [SwiftDataModelGroup: [any PersistentModel.Type]] = [:]
    private var configurations: [SwiftDataModelGroup: ModelConfiguration] = [:]
    private var containers: [SwiftDataModelGroup: ModelContainer] = [:]

    // MARK: - Init
    private init(
        modelFactory: SwiftDataServiceModelFactory = SwiftDataServiceModelFactoryImpl(),
        fileFactory: SwiftDataServiceFileFactory = SwiftDataServiceFileFactoryImpl(),
        fileEncryptor: FileEncryptor = FileEncryptorImpl()
    ) {
        _modelFactory = modelFactory
        _fileFactory = fileFactory
        _fileEncryptor = fileEncryptor
    }

    // MARK: - Service methods
    func register(group: SwiftDataModelGroup) {
        let models = _modelFactory.makeModel(for: group)
        if var existing = modelGroups[group] {
            existing.append(contentsOf: models)
            modelGroups[group] = existing
        } else {
            modelGroups[group] = models
        }
    }

    func container(for group: SwiftDataModelGroup) throws(SwiftDataServiceError) -> ModelContainer {
        if let container = containers[group] {
            return container
        }

        guard let models = modelGroups[group], !models.isEmpty else {
            throw SwiftDataServiceError.noModelRegistered
        }

        let schema = Schema(models)
        let url = _fileFactory.makeFile(for: group)
        _encryptFile(at: url)

        let configuration: ModelConfiguration
        if let cachedConfiguration = configurations[group] {
            configuration = cachedConfiguration
        } else {
            configuration = ModelConfiguration(schema: schema, url: url, allowsSave: true)
            configurations[group] = configuration
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


        containers[group] = newContainer
        return newContainer
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

    @MainActor
    func context(for group: SwiftDataModelGroup) throws(SwiftDataServiceError) -> ModelContext {
        do {
            return try container(for: group).mainContext
        } catch {
            throw SwiftDataServiceError.failedToRecreateStore(storeError: error, recreationError: error)
        }
    }

    func resetContainer(for group: SwiftDataModelGroup) {
        containers.removeValue(forKey: group)
        let customURL = _fileFactory.makeFile(for: group)
        _removeOldStoreFiles(at: customURL)
    }

    func resetAllContainers() {
        for group in SwiftDataModelGroup.allCases {
            resetContainer(for: group)
        }
    }
}

// MARK: - ModelGroup
enum SwiftDataModelGroup: String, CaseIterable {
    case song
}

// MARK: - SwiftDataServiceModelFactory
@available(iOS 17, *)
protocol SwiftDataServiceModelFactory {
    func makeModel(for group: SwiftDataModelGroup) -> [any PersistentModel.Type]
}

@available(iOS 17, *)
struct SwiftDataServiceModelFactoryImpl: SwiftDataServiceModelFactory {
    func makeModel(for group: SwiftDataModelGroup) -> [any PersistentModel.Type] {
        switch group {
            case .song: [
                MelodyDataModel.self
            ]
        }
    }
}
