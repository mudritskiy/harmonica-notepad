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

//    var titleWidth: CGFloat {
//        let displayText = text.isEmpty ? placeholder : text
//        let font = UIFont.systemFont(ofSize: 17)
//        let attributes = [NSAttributedString.Key.font: font]
//        let size = (displayText as NSString).size(withAttributes: attributes)
//        return size.width
//    }

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                TextField(placeholder, text: $text, axis: .vertical)
                    .font(.title3.bold())
                    .multilineTextAlignment(.leading)
                    .textFieldStyle(.plain)
                    .onChange(of: text) { oldValue, newValue in
                        if limit > 0, newValue.count > limit {
                            text = String(newValue.prefix(limit))
                        }
                    }
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
