//
//  HarmonicaEditFieldRounded.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.10.2025.
//

import SwiftUI

struct HarmonicaTextEditFieldRounded: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let limit: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(FontToken.body2.value)
                    .foregroundColor(Theme.colors.text.tertiary.color)
                    .padding(.leading, 8)
            CardContainer {
                TextField(placeholder, text: $text, axis: .vertical)
                    .font(FontToken.headline.value)
                    .foregroundColor(Theme.colors.text.primary.color)
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(.plain)
                    .onChange(of: text) { oldValue, newValue in
                        if limit > 0, newValue.count > limit {
                            text = String(newValue.prefix(limit))
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    HarmonicaEditFieldPreview()
}

private struct HarmonicaEditFieldPreview: View {
    @State private var text = "Sample text"

    var body: some View {
        HarmonicaTextEditFieldRounded(
            title: "Title",
            placeholder: "Input song title",
            text: $text,
            limit: 30
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
