//
//  HarmonicaLayoutConfiguration.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.03.2026.
//

import SwiftUI

@Observable
final class HarmonicaLayoutConfiguration {
    var bendsLevel: NoteTechnique.BendLevel
    var isOverbandsOn: Bool
    var isDrawBendsOn: Bool
    var isBlowBendsOn: Bool

    init(
        bendsLevel: NoteTechnique.BendLevel = .level3,
        isOverbandsOn: Bool = true,
        isDrawBendsOn: Bool = true,
        isBlowBendsOn: Bool = true
    ) {
        self.bendsLevel = bendsLevel
        self.isOverbandsOn = isOverbandsOn
        self.isDrawBendsOn = isDrawBendsOn
        self.isBlowBendsOn = isBlowBendsOn
    }
}

extension HarmonicaLayoutConfiguration {
    struct ConfigSnapshot: Equatable {
        let bendsLevel: NoteTechnique.BendLevel
        let isOverbandsOn: Bool
        let isDrawBendsOn: Bool
        let isBlowBendsOn: Bool
    }
}
