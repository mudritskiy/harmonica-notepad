//
//  AppDelegate.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 24.03.2026.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {

    static var orientationLock: UIInterfaceOrientationMask = .all

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        Self.orientationLock
    }
}
