//
//  MelodyToolbarButtonBackgroundView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.03.2026.
//

import SwiftUI

struct MelodyToolbarButtonConstants {
    static let size = CGSize(width: 100, height: 36)
}

struct MelodyToolbarButtonBackgroundView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Theme.colors.background.primaryTinted.color)
            .shadow(
                color: Theme.colors.background.shadow.color,
                radius: 1,
                x: 1,
                y: 1
            )
    }
}
