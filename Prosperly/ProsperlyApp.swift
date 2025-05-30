//
//  ProsperlyApp.swift
//  Prosperly
//
//  Created by Jeff Goodwin on 5/30/25.
//

import SwiftUI

@main
struct ProsperlyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
