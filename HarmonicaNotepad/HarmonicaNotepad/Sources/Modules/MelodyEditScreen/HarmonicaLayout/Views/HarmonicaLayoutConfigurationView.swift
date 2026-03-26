//
//  HarmonicaLayoutConfigurationView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.06.2025.
//

import SwiftUI

struct HarmonicaLayoutConfigurationView: View {
    @Environment(HarmonicaLayoutConfiguration.self) private var config: HarmonicaLayoutConfiguration

    var body: some View {
        @Bindable var bindableConfig = config
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Bend Level")
                            .font(FontToken.headline.value)
                            .foregroundStyle(Theme.colors.text.secondary.color)

                        Spacer()

                        ForEach(NoteTechnique.BendLevel.allCases, id: \.self) { level in
                            BendButtonView(
                                level: level,
                                isSelected: bindableConfig.bendsLevel == level
                            ) {
                                bindableConfig.bendsLevel = level
                            }
                        }
                    }
                } header: {
                    Text("Bends")
                        .font(FontToken.title3.value)
                        .foregroundStyle(Theme.colors.text.primary.color)
                }

                Section {
                    CheckboxView(
                        title: "Overbands",
                        isChecked: $bindableConfig.isOverbandsOn
                    )
                    CheckboxView(
                        title: "Blow bends",
                        isChecked: $bindableConfig.isBlowBendsOn
                    )
                    CheckboxView(
                        title: "Draw bends",
                        isChecked: $bindableConfig.isDrawBendsOn
                    )
                } header: {
                    Text("Techniques")
                        .font(FontToken.title3.value)
                        .foregroundStyle(Theme.colors.text.primary.color)
                }
            }
            .navigationTitle("Layout Configuration")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct CheckboxView: View {
    let title: String
    @Binding var isChecked: Bool

    var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            HStack {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .font(FontToken.body2.value)
                    .foregroundStyle(Theme.colors.text.secondary.color)
                    .imageScale(.large)

                Text(title)
                    .font(FontToken.headline.value)
                    .foregroundStyle(Theme.colors.text.secondary.color)

                Spacer()
            }
            .contentShape(Rectangle())   // makes whole row tappable
        }
        .buttonStyle(.plain)
    }
}

private struct BendButtonView: View {
    let level: NoteTechnique.BendLevel
    let isSelected: Bool
    let onTap: () -> Void

    var borderColor: Color {
        isSelected ? Theme.colors.text.secondary.color : .clear
    }
    var body: some View {
        Button {
            onTap()
        } label: {
            Text(String(level.rawValue))
                .font(FontToken.headline.value)
                .foregroundStyle(Theme.colors.text.secondary.color)
                .frame(width: 36, height: 36)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}
