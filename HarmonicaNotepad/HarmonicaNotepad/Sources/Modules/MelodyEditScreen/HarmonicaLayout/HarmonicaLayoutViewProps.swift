//
//  HarmonicaLayoutViewProps.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.03.2026.
//

import SwiftUI

struct HarmonicaLayoutViewProps: Equatable {
    let notesGrid: HarmonicaLayoutNotesGrid
    let systemKeyboardRowsCount: Int
    let keySize: CGSize

    let font: FontToken
    let fontColor: ColorToken
    let backgroundColor: ColorToken
    let serviceKeyboardProps: ServiceKeyboardProps

    let onNoteTap: (HarmonicaNote) -> Void

    init(
        congif: HarmonicaLayoutConfiguration,
        notesGrid: HarmonicaLayoutNotesGrid,
        font: FontToken,
        fontColor: ColorToken = Theme.colors.text.contrastSecondary,
        backgroundColor: ColorToken = Theme.colors.background.primaryTinted,
        serviceKeyboardEvents: EventStream<ServiceKeyboardEvent>,
        onNoteTap: @escaping (HarmonicaNote) -> Void
    ) {
        let fontCharWidth = font.size(with: "W")
        let keyWidth = fontCharWidth * 1.5
        let keySize = CGSize(width: keyWidth, height: keyWidth * 1.35)

        let serviceKeyboardProps = ServiceKeyboardProps(
            cornerRadius: 8,
            keySize: keySize,
            font: font,
            fontColor: fontColor.color,
            backgroundColor: Theme.colors.text.tertiary.color.opacity(0.25),
            borderColor: Theme.colors.background.primaryTinted.color,
            events: serviceKeyboardEvents
        )

        var systemKeyboardRowsCount: Int = 2
        let drawRowsCount = notesGrid.rowsCount - notesGrid.holesRowIndex
        if drawRowsCount == 4 {
            systemKeyboardRowsCount = 0
        } else if drawRowsCount == 3 {
            systemKeyboardRowsCount = congif.isOverbandsOn ? 1 : 0
        } else if drawRowsCount == 2 {
            systemKeyboardRowsCount = congif.isOverbandsOn ? 2 : 1
        }

        self.notesGrid = notesGrid
        self.systemKeyboardRowsCount = systemKeyboardRowsCount
        self.keySize = keySize
        self.font = font
        self.fontColor = fontColor
        self.backgroundColor = backgroundColor
        self.serviceKeyboardProps = serviceKeyboardProps
        self.onNoteTap = onNoteTap
    }

    static func == (lhs: HarmonicaLayoutViewProps, rhs: HarmonicaLayoutViewProps) -> Bool {
        lhs.notesGrid == rhs.notesGrid &&
        lhs.systemKeyboardRowsCount == rhs.systemKeyboardRowsCount &&
        lhs.keySize == rhs.keySize &&
        lhs.font == rhs.font &&
        lhs.fontColor.color == rhs.fontColor.color &&
        lhs.backgroundColor.color == rhs.backgroundColor.color &&
        lhs.serviceKeyboardProps == rhs.serviceKeyboardProps
    }
}
