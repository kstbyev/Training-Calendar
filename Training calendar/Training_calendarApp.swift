//
//  Training_calendarApp.swift
//  Training calendar
//
//  Created by Madi Sharipov on 11.12.2025.
//

import SwiftUI
import CoreData

@main
struct Training_calendarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
