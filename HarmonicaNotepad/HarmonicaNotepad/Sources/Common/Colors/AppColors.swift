//
//  AppColors.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.03.2026.
//

struct AppColors {
    let background: Background
    let text: Text
    let icon: Icon
    let songList: SongList

    struct Background {
        let primary: ColorToken
        let primaryTinted: ColorToken
        let secondary: ColorToken
        let accent: ColorToken
        let highlight: ColorToken
        let draw: ColorToken
        let blow: ColorToken
        let shadow: ColorToken
    }

    struct Text {
        let primary: ColorToken
        let secondary: ColorToken
        let tertiary: ColorToken
        let contrast: ColorToken
        let contrastSecondary: ColorToken
        let contrastTertiary: ColorToken
        let accent: ColorToken
        let highlight: ColorToken
    }

    struct Icon {
        let primary: ColorToken
        let secondary: ColorToken
        let accent: ColorToken
    }

    struct SongList {
        let backgoundSelected: ColorToken
        let borderSelected: ColorToken
        let textSelected: ColorToken
        let backgound: ColorToken
    }
}

extension AppColors {
    static let `default` = AppColors(
        background: Background(
            primary: .from(light: \.neutral10, dark: \.neutral10),
            primaryTinted: .from(light: \.neutral20, dark: \.neutral20),
            secondary: .from(light: \.sand30, dark: \.sand30), //sand20
            accent: .from(light: \.clay40, dark: \.clay40), //sand60
            highlight: .from(light: \.slate50, dark: \.slate50),
            draw: .from(light: \.draw, dark: \.draw),
            blow: .from(light: \.blow, dark: \.blow),
            shadow: .from(light: \.shadow, dark: \.shadow)
        ),

        text: Text(
            primary: .from(light: \.lavaBlack90, dark: \.lavaBlack90),
            secondary: .from(light: \.lavaBlack60, dark: \.lavaBlack60),
            tertiary: .from(light: \.lavaBlack10, dark: \.lavaBlack10),
            contrast: .from(light: \.lavaBlackPersistant90, dark: \.lavaBlackPersistant90),
            contrastSecondary: .from(light: \.lavaBlackPersistant10, dark: \.lavaBlackPersistant30),
            contrastTertiary: .from(light: \.lavaBlackPersistant10, dark: \.lavaBlackPersistant10),
            accent: .from(light: \.slate50, dark: \.slate50),
            highlight: .from(light: \.sand10, dark: \.sand10)

//            primary: .from(light: \.ink90, dark: \.ink90),
//            secondary: .from(light: \.ink10, dark: \.ink10),
//            accent: .from(light: \.slate50, dark: \.slate50),
//            highlight: .from(light: \.sand10, dark: \.sand10)
        ),

        icon: Icon(
            primary: .from(light: \.lavaBlack90, dark: \.lavaBlack90),
            secondary: .from(light: \.lavaBlack60, dark: \.lavaBlack60),
            accent: .from(light: \.lavaBlackPersistant30, dark: \.lavaBlackPersistant30)
        ),

        songList: SongList(
            backgoundSelected: .from(light: \.lavaBlackPersistant70, dark: \.neutral10),
            borderSelected: .from(light: \.lavaBlackPersistant70, dark: \.lavaBlackPersistant70),
            textSelected: .from(light: \.lavaBlackPersistant10, dark: \.lavaBlackPersistant70),
            backgound: .from(light: \.neutral10, dark: \.neutral10)
        )
    )
}
