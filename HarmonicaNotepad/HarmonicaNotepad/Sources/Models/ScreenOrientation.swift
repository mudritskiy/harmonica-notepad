//
//  ScreenOrientation.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 24.03.2026.
//

import UIKit

enum ScreenOrientation {

    static func lock(_ orientation: UIInterfaceOrientationMask) {
        AppDelegate.orientationLock = orientation
    }

    static func unlock() {
        AppDelegate.orientationLock = .all
    }
}
