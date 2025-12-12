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
    @State private var navigationPath = NavigationPath()
    private let coordinator = AppCoordinator()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            coordinator.buildRootView(path: $navigationPath)
                .environment<NSManagedObjectContext>(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.none) // Allow system theme
        }
    }
}
