//
//  MelodyNotePresenetionStyle.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 31.03.2026.
//

import SwiftUI

enum MelodyNotePresenetionStyle {
    case numbersPrimary

    var width: CGFloat {
        switch self {
            case .numbersPrimary:
                let props = MelodyNotePresenetionNumberPrimaryViewProps()
                return props.directionWidth + props.holeWidth + props.techniqueWidth
        }
    }

    var height: CGFloat {
        switch self {
            case .numbersPrimary:
                let props = MelodyNotePresenetionNumberPrimaryViewProps()
                return props.baseFont.size(with: "W")
        }
    }

    @ViewBuilder
    func makeView(state: MelodyNotePresenetionState) -> some View {
        switch self {
            case .numbersPrimary:
                let props = MelodyNotePresenetionNumberPrimaryViewProps()
                MelodyNotePresenetionNumberPrimaryView(state: state, props: props)
        }
    }
}

struct MelodyNotePresenetionState {
    let note: HarmonicaNote
    let type: MelodyNoteType
    let isPlaying: Bool
}
