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
    @State private var isOnboardingPassed = UserDefaultsManager.shared.getBool(forKey: .isOnboarded)
    @StateObject private var onboardingVM = OnboardingViewModel()
    @StateObject private var addDocVM = AddDocumentViewModel()

    var body: some Scene {
        WindowGroup {
            if isOnboardingPassed {
                AddDocumentView(viewModel: addDocVM)
                    .preferredColorScheme(.light)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                OnboardingView(viewModel: onboardingVM, isOnboardingPassed: $isOnboardingPassed)
                    .preferredColorScheme(.light)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            
        }
    }
}
