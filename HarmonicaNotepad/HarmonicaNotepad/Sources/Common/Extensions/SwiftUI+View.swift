//
//  View.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.06.2025.
//

import SwiftUI

public extension View {
    func stretching(_ axis: Axis = .horizontal, alignment: Alignment = .leading) -> some View {
        frame(
            maxWidth: axis == .horizontal ? .infinity : nil,
            maxHeight: axis == .vertical ? .infinity : nil,
            alignment: alignment
        )
    }
}
