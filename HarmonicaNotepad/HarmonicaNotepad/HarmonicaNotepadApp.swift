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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
