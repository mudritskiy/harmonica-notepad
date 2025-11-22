//
//  HarmonicaTextEditField.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.10.2025.
//

import SwiftUI

struct HarmonicaTextEditField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var titleWidth: CGFloat {
        let displayText = text.isEmpty ? placeholder : text
        let font = UIFont.systemFont(ofSize: 17)
        let attributes = [NSAttributedString.Key.font: font]
        let size = (displayText as NSString).size(withAttributes: attributes)
        return size.width
    }

    var body: some View {
        Rectangle()
            .frame(
                width: titleWidth + 32,
                height: 0.5
            )
            .foregroundColor(.gray)
            .animation(.easeInOut, value: titleWidth)
        VStack(spacing: 4) {
            TextField(placeholder, text: $text)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .textFieldStyle(.plain)
            Rectangle()
                .frame(
                    width: titleWidth + 32,
                    height: 0.5
                )
                .foregroundColor(.gray)
                .animation(.easeInOut, value: titleWidth)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.top, 4)
        }
    }
}
