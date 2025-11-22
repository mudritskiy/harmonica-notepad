//
//  HarmonicaNotepadApp.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 11.07.2024.
//

import SwiftUI

@main
struct HarmonicaNotepadApp: App {
    let persistenceController = PersistenceController.shared
    @Bindable private var _appNavigation = AppNavigationModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(_appNavigation)
        }
    }
}
