//
//  HarmonicaLayoutView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.05.2025.
//

import Combine
import SwiftUI
import MusicTheory

@Observable
final class HarmonicaLayoutViewModel {
    var notesGrid: LayoutNotesGrid
    var isPresentedKeySetup: Bool = false

    private var _configuration: HarmonicaLayoutConfiguration
    private let _layout: HarmonicaLayout

    @ObservationIgnored let layoutConfigurationViewModel: HarmonicaLayoutConfigurationViewModel
    @ObservationIgnored let notePublisher = PassthroughSubject<HarmonicaNote, Never>()

    init(
        layout: HarmonicaLayout = HarmonicaLayout(key: Key(type: .c))
    ) {
        let configuration = HarmonicaLayoutConfiguration()
        let notes = layout.notes(by: configuration)
        notesGrid = LayoutNotesGrid(with: notes)

        _layout = layout
        _configuration = configuration

        layoutConfigurationViewModel = HarmonicaLayoutConfigurationViewModel(
            configuration: configuration
        )
    }

    func updateNoteGrid(with layout: HarmonicaLayout) {
        let notes = layout.notes(by: _configuration)
        notesGrid = LayoutNotesGrid(with: notes)
    }

    func applyConfiguration() {
        _configuration = layoutConfigurationViewModel.configuration
        updateNoteGrid(with: _layout)
    }

    func onNoteTap(_ note: HarmonicaNote) {
        notePublisher.send(note)
    }
}

struct HarmonicaLayoutView: View {
    @Bindable var viewModel: HarmonicaLayoutViewModel

    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
                .stretching(.vertical)
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(1...viewModel.notesGrid.rowsCount, id: \.self) { row in
                    GridRow {
                        ForEach(viewModel.notesGrid.holesRange, id: \.self) { hole in
                            _cellContent(row: row, hole: hole)
                        }
                    }
                }
            }
            .background(Color.gray.opacity(0.2))
            SwiftUI.Button(role: .none) {
                viewModel.isPresentedKeySetup = true
            } label: {
                HStack(spacing: .zero) {
                    Text("Settings")
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Constants.melodyActionButtonSize, height: Constants.melodyActionButtonSize)
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .purple.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(4)
            }
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.purple.opacity(0.7), lineWidth: 1)
                    .foregroundStyle(.purple)
            }
            Spacer()
                .stretching(.vertical)
        }
        .sheet(isPresented: $viewModel.isPresentedKeySetup) {
            HarmonicaLayoutConfigurationView(viewModel: viewModel.layoutConfigurationViewModel)
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(false)
                .presentationBackgroundInteraction(.disabled)
                .presentationContentInteraction(.resizes)
        }
        .onChange(of: viewModel.isPresentedKeySetup) { oldValue, newValue in
            guard oldValue else { return }
            viewModel.applyConfiguration()
        }
    }

    @ViewBuilder
    private func _cellContent(row: Int, hole: Int) -> some View {
        if let note = viewModel.notesGrid[(row - 1), hole] {
            HoleCell(note: note) {
                viewModel.onNoteTap(note)
            }
        } else if row == viewModel.notesGrid.holesRowIndex {
            Text("\(hole)")
                .frame(minWidth: 30, maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .background(Color.gray.opacity(0.2))
        } else {
            Spacer()
                .aspectRatio(1, contentMode: .fill)
        }
    }
}

