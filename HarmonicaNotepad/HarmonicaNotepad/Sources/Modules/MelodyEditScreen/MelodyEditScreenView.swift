//
//  MelodyEditScreenView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.05.2025.
//

import SwiftUI

struct MelodyEditScreenView: View {
    @Bindable var viewModel: MelodyEditScreenViewModel
    @Environment(HarmonicaLayoutConfiguration.self) private var config: HarmonicaLayoutConfiguration
    @Environment(\.dismiss) var dismiss

    private var configSnapshot: HarmonicaLayoutConfiguration.ConfigSnapshot {
        HarmonicaLayoutConfiguration.ConfigSnapshot(
            bendsLevel: config.bendsLevel,
            isOverbandsOn: config.isOverbandsOn,
            isDrawBendsOn: config.isDrawBendsOn,
            isBlowBendsOn: config.isBlowBendsOn
        )
    }

    var body: some View {
        _contentView()
            .screenBaseStyle()
            .screenToolbars(viewModel: viewModel)
            .screenLifecycle(viewModel: viewModel, dismiss: dismiss)
            .alertInfo(isPresented: $viewModel.showAlert, viewModel.alertInfo)
            .sheet(item: $viewModel.activeSheet, content: _sheetView)
            .onChange(of: configSnapshot) { _, _ in
                viewModel.applyConfiguration(with: config)
            }
    }

    private func _contentView() -> some View  {
        VStack {
            ZStack(alignment: .bottom) {
                MelodyNotesPresentationView(
                    props: MelodyNotesPresentationViewProps(
                        melodyRows: viewModel.melodyRows,
                        playerEventStream: viewModel.playerEventStream()
                    ),
                    cursorIndex: $viewModel.cursorIndex
                )
                .stretching(.vertical)

                _melodyToolbarView()
            }
            .padding(.horizontal, 16)

            if let layoutViewProps = viewModel.layoutViewProps {
                HarmonicaLayoutView(props: layoutViewProps)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
            }
        }
        .animation(.snappy, value: viewModel.layoutViewProps)
    }

    private func _melodyToolbarView() -> some View {
        MelodyToolbarView(
            props: viewModel.melodyToolbarViewProps()
        )
    }

    // MARK: - Sheets
    @ViewBuilder
    private func _sheetView(_ sheet: MelodyEditScreenViewModel.ActiveSheet) -> some View {
        Group {
            switch sheet {
                case .tempo:
                    TempoSetupView(tempo: viewModel.tempo.bpm) { tempo in
                        viewModel.onTempoChange(to: tempo)
                    }
                    .presentationDetents([.large])
                case .key:
                    KeySetupView(key: viewModel.key) { key in
                        viewModel.onKeyChange(to: key)
                    }
                    .presentationDetents([.medium])
                case .layout:
                    HarmonicaLayoutConfigurationView()
                        .presentationDetents([.fraction(0.6)])
            }
        }
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(false)
        .presentationBackgroundInteraction(.disabled)
        .presentationContentInteraction(.resizes)
    }
}

// MARK: - Base screen style
private extension View {
    func screenBaseStyle() -> some View {
        self
            .background(Theme.colors.background.primary.color)
            .toolbarVisibility(.hidden, for: .tabBar)
            .navigationBarBackButtonHidden()
    }
}

// MARK: - Toolbar
private extension View {
    func screenToolbars(viewModel: MelodyEditScreenViewModel) -> some View {
        self.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.onCancelTap()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.onPasteTap()
                } label: {
                    Image(systemName: "rectangle.portrait.badge.plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.onApplyTap()
                } label: {
                    Text("Apply")
                }
            }
        }
    }
}

// MARK: - Lifecycle
private extension View {
    func screenLifecycle(
        viewModel: MelodyEditScreenViewModel,
        dismiss: DismissAction
    ) -> some View {
        self
            .onFirstAppear {
                viewModel.dismiss = { dismiss() }
            }
            .onAppear {
                ScreenOrientation.lock(.portrait)
            }
            .onDisappear {
                ScreenOrientation.unlock()
            }
            .task {
                for await event in viewModel.serviceKeyboardEvents.stream {
                    viewModel.onServiceKeyTap(event)
                }
            }
    }
}
