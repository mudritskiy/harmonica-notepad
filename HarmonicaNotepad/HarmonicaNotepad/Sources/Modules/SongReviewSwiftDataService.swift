//
//  SongReviewSwiftDataService.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 29.06.2025.
//

import Foundation
import SwiftData

protocol SongSwiftDataService {
//    var isAvailable: Bool { get }
//    func saveReview(with model: WriteReviewModel)
//    func fetchReview(by productId: Product.Id) async -> WriteReviewModel?
}

final class SongSwiftDataServiceImpl: SongSwiftDataService {
    private let _service: SwiftDataService
//
//    let isAvailable: Bool = true
    private let _modelGroup: SwiftDataModelGroup = .song
//
    init(service: SwiftDataService = SwiftDataServiceImpl.shared) {
        service.register(group: _modelGroup)
        _service = service
    }

    func saveSong(with model: HarmonicaSong) {
        let data = HarmonicaSongDataModel(
            id: model.id.rawValue,
            title: model.title
        )
        Task {
            await _saveReviewData(data)
        }
    }

    private func _saveMelody()
//
    @MainActor
    private func _saveReviewData(_ data: HarmonicaSongDataModel) async {
        let descriptor = _reviewDescriptor(by: data.id)
        guard let context = try? _service.context(for: _modelGroup) else { return }

        if let review = try? context.fetch(descriptor).first {
            review.rate = data.rate
            review.mainText = data.mainText
        } else {
            context.insert(data)
        }
    }
//
//    func fetchReview(by productId: Product.Id) async -> WriteReviewModel? {
//        await _fetchReviewData(by: productId.value)
//    }
//
//    @MainActor
//    private func _fetchReviewData(by id: Int) async -> WriteReviewModel? {
//        let descriptor = _reviewDescriptor(by: id)
//        guard let context = try? _service.context(for: _modelGroup),
//              let review = try? context.fetch(descriptor).first
//        else { return nil }
//
//        let model = WriteReviewModel()
//        model.rate = review.rate
//        model.mainText = review.mainText
//        return model
//    }
//
    private func _reviewDescriptor(by id: Int) -> FetchDescriptor<HarmonicaSongDataModel> {
        var descriptor = FetchDescriptor<HarmonicaSongDataModel>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return descriptor
    }
}
