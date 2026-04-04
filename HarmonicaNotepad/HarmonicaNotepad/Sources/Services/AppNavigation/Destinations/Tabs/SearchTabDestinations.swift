//
//  SearchTabDestinations.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 04.04.2026.
//

import SwiftUI

struct SearchTabDestinations: ViewModifier {
    func body(content: Content) -> some View {
        content
            .modifier(SongScreenDestinations())
            .modifier(SearchListDestinations())
    }
}
