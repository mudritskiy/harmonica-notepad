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

    let font: FontToken
    let fontCharWidth: CGFloat
    let keySize: CGSize

    private var _configuration: HarmonicaLayoutConfiguration
    private let _layout: HarmonicaLayout
    private let _backgroundColor: ColorToken = Theme.colors.background.primaryTinted

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

        let font = FontToken.title3
        self.font = font
        fontCharWidth = "W".size(withAttributes: [.font: font.uiFont]).width
        let keyWidth = fontCharWidth * 1.5
        keySize = CGSize(width: keyWidth, height: keyWidth * 1.35)
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
        _keyboardContainerView()
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

    private func _keyboardContainerView() -> some View {
        CardContainer(
            cornerRadius: 24,
            borderWidth: 1,
            backgroundColor:_backgroundColor.color,
            borderColor: _backgroundColor.color
        ) {
            _keyboardView()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
        }
        .themeShadow()
    }

    private func _keyboardView() -> some View {
        VStack(spacing: .zero) {
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(1...viewModel.notesGrid.rowsCount, id: \.self) { row in
                    GridRow {
                        ForEach(viewModel.notesGrid.holesRange, id: \.self) { hole in
                            _cellContent(row: row, hole: hole)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func _cellContent(row: Int, hole: Int) -> some View {
        if let note = viewModel.notesGrid[(row - 1), hole] {
            HoleCell(note: note, font: viewModel.font, keySize: viewModel.keySize) {
                viewModel.onNoteTap(note)
            }
            .shadow(
                color: Theme.colors.background.shadow.color,
                radius: 1,
                x: 0,
                y: 0
            )
            .padding(2)
      } else if row == viewModel.notesGrid.holesRowIndex {
            Text("\(hole)")
                .font(viewModel.font.value)
                .foregroundStyle(Theme.colors.text.contrastSecondary.color)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    Theme.colors.background.accent.color
                        .clipShape(
                            RoundedCorner(
                                radius: 8,
                                corners: _corners(with: hole)
                            )
                        )
                )
                .padding(.vertical, 2)
        } else {
            Spacer()
//                .aspectRatio(1, contentMode: .fill)
        }
    }

    private func _corners(with hole: Int) -> UIRectCorner {
        switch hole {
            case 1: [.topLeft, .bottomLeft]
            case 10: [.topRight, .bottomRight]
            default: []
        }
    }

    private func _buttonSettings() -> some View {
        SwiftUI.Button(role: .none) {
            viewModel.isPresentedKeySetup = true
        } label: {
            _buttonSettingsContent()
                .padding(4)
        }
        .background {
            RoundedRectangle(cornerRadius: 12)
                .stroke(.purple.opacity(0.7), lineWidth: 1)
                .foregroundStyle(.purple)
        }
    }

    private func _buttonSettingsContent() -> some View {
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
    }
}

