//
//  ContentView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 11.07.2024.
//

import SwiftUI
import MusicTheory

struct ContentView: View {
    var body: some View {
        MelodyEditScreenView(
            viewModel: MelodyEditScreenViewModel()
        )
//        NoteView()
//            .padding()
    }
}


