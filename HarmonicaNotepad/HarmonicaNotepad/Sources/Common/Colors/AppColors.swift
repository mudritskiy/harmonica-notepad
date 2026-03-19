//
//  AppColors.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.03.2026.
//

struct AppColors {
    let background: Background
    let text: Text

    struct Background {
        let primary: ColorToken
        let secondary: ColorToken
        let accent: ColorToken
        let highlight: ColorToken
    }

    struct Text {
        let primary: ColorToken
        let secondary: ColorToken
        let accent: ColorToken
        let highlight: ColorToken
    }
}

extension AppColors {
    static let `default` = AppColors(
        background: .init(
            primary: .from(light: \.sand10, dark: \.sand10),
            secondary: .from(light: \.sand20, dark: \.sand20),
            accent: .from(light: \.sand60, dark: \.sand60),
            highlight: .from(light: \.slate50, dark: \.slate50)
        ),

        text: .init(
            primary: .from(light: \.ink90, dark: \.ink90),
            secondary: .from(light: \.ink60, dark: \.ink60),
            accent: .from(light: \.slate50, dark: \.slate50),
            highlight: .from(light: \.sand10, dark: \.sand10)
        )
    )
}
