//
//  PDF_RedactorApp.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 16.09.2025.
//

import SwiftUI
import CoreData

@main
struct PDF_RedactorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
