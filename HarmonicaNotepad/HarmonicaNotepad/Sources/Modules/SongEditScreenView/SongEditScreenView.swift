//
//  SongEditScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 22.06.2025.
//

import MusicTheory
import SwiftData
import SwiftUI

struct SongEditScreenView: View {
    @Bindable private var _viewModel: SongEditScreenViewModel
    @Binding private var _hasUnsavedChanges: Bool

    @Environment(\.modelContext) private var _context
    @Environment(\.dismiss) private var dismiss

    init(viewModel: SongEditScreenViewModel, hasUnsavedChanges: Binding<Bool> = .constant(false)) {
        _viewModel = viewModel
        __hasUnsavedChanges = hasUnsavedChanges
    }

    var body: some View {
        ScrollView {
            _contentView()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .navigationTitle("Description")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    _viewModel.saveProperties()
                    _hasUnsavedChanges = true
                    dismiss()
                } label: {
                    Image(systemName: "checkmark")
                }
            }
        }
        .onFirstAppear {
            _viewModel.modelContext = _context
//            _hasUnsavedChanges = false
        }
        .background(Theme.colors.background.primary.color)
    }

    private func _contentView() -> some View {
        VStack(alignment: .center, spacing: .zero) {
            _fieldsContent()
            Spacer()
        }

    }

    private func _fieldsContent() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(HarmonicaSongProperty.allCases, id: \.self) { property in
                HarmonicaTextEditFieldRounded(
                    title: _viewModel.songProperties.placeholder(for: property),
                    placeholder: _viewModel.songProperties.placeholder(for: property),
                    text: _viewModel.binding(for: property),
                    limit: 0
                )
            }
        }
    }
}
