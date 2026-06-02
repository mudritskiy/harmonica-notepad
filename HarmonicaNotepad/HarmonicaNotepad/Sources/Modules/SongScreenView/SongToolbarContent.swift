//
//  ToolbarContent.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 23.03.2026.
//

import SwiftUI

struct SongToolbarContent: ToolbarContent {
    // MARK: - Properties
    let isApplyButtonVisible: Bool
    let onDismiss: () -> Void
    let onDeleteTap: () -> Void
    let onListsTap: () -> Void
    let onSaveTap: () -> Void

    // MARK: - Constants
    private var _itemsInsets: CGFloat { isApplyButtonVisible ? 4 : 0 }

    // MARK: - Render
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(FontToken.body2.value)
                    .foregroundStyle(Theme.colors.icon.secondary.color)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button(action: onDeleteTap) {
                Image(systemName: "trash")
                    .font(FontToken.body2.value)
                    .foregroundStyle(Theme.colors.icon.accent.color)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            HStack(alignment: .center, spacing: _itemsInsets) {
                Button(action: onListsTap) {
                    Image(systemName: "heart")
                        .font(FontToken.body1.value)
                        .foregroundStyle(Theme.colors.icon.secondary.color)
                }
                .padding(.leading, _itemsInsets)

                if isApplyButtonVisible {
                    Button(action: onSaveTap) {
                        Image(systemName: "checkmark")
                            .font(FontToken.body1.value)
                            .foregroundStyle(Theme.colors.icon.secondary.color)
                    }
                    .padding(.trailing, _itemsInsets)
                }
            }
        }
    }
}
