//
//  HarmonicaLayoutConfigurationView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.06.2025.
//

import SwiftUI

struct HarmonicaLayoutConfiguration {
    var bendsLevel: NoteTechnique.BendLevel
    var isOverbandsOn: Bool
    var isDrawBendsOn: Bool
    var isBlowBendsOn: Bool

    init(
        bendsLevel: NoteTechnique.BendLevel = .level3,
        isOverbandsOn: Bool = true,
        isDrawBendsOn: Bool = true,
        isBlowBendsOn: Bool = true
    ) {
        self.bendsLevel = bendsLevel
        self.isOverbandsOn = isOverbandsOn
        self.isDrawBendsOn = isDrawBendsOn
        self.isBlowBendsOn = isBlowBendsOn
    }
}

final class HarmonicaLayoutConfigurationViewModel: ObservableObject {
    @Published var configuration: HarmonicaLayoutConfiguration

    init(
        configuration: HarmonicaLayoutConfiguration,
    ) {
        self.configuration = configuration
    }

    func updateConfiguraion(with bendsLevel: NoteTechnique.BendLevel) {
        configuration.bendsLevel = bendsLevel
    }
}

struct HarmonicaLayoutConfigurationView: View {
    @ObservedObject var _viewModel: HarmonicaLayoutConfigurationViewModel

    init(viewModel: HarmonicaLayoutConfigurationViewModel) {
        _viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("Bends:")
                ForEach(NoteTechnique.BendLevel.allCases, id: \.self) { level in
                    HarmonicaLayoutConfigurationBendButtonView(
                        level: level,
                        isSelected: _viewModel.configuration.bendsLevel == level
                    ) {
                        _viewModel.updateConfiguraion(with: level)
                    }
                }
            }
            CheckboxView(title: "Overbands", isChecked: $_viewModel.configuration.isOverbandsOn)
            CheckboxView(title: "Blow bends", isChecked: $_viewModel.configuration.isBlowBendsOn)
            CheckboxView(title: "Draw bends", isChecked: $_viewModel.configuration.isDrawBendsOn)
        }
        .padding(16)
    }
}

struct CheckboxView: View {
    let title: String
    @Binding var isChecked: Bool

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square" : "square")
                Text(title)
            }
        }
        .buttonStyle(.plain)
    }
}

struct HarmonicaLayoutConfigurationBendButtonView: View {
    let level: NoteTechnique.BendLevel
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            Text(level.description)
                .frame(width: 44, height: 44)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? .gray.opacity(0.25) : .clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.purple.opacity(0.7), lineWidth: 1)
                        )
                }
        }
    }
}
