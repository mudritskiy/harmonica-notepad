//
//  ContentView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 11.07.2024.
//

import SwiftUI
import MusicTheory

struct ContentView: View {
    init() {
        let layout = HarmonicaLayout(key: Key(type: .c))
    }

    var body: some View {
        NoteView()
            .padding()
    }
}
