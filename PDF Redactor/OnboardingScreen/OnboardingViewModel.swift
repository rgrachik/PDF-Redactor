//
//  OnboardingViewModel.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 17.09.2025.
//

import Combine
import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Constants
    
    private enum Constants {
        
    }
    
    // MARK: - Properties
    
    @Published var image: ImageResource = ImageResource(name: "pdfGet", bundle: .main)
    @Published var title: String = .getWord(by: "greeting")
    @Published var subtitle: String = .getWord(by: "onboardingDescription1")
    @Published var buttonTitle: String = .getWord(by: "nextTitile")
    @Published var step: Int = .zero
    
    func nextStep() {
        step += 1
        switch step {
        case 1:
            image = ImageResource(name: "pdfRead", bundle: .main)
            title = .getWord(by: "onboardingTitle1")
            subtitle = .getWord(by: "onboardingDescription2")
            buttonTitle = .getWord(by: "nextTitile")
        case 2:
            image = ImageResource(name: "pdfExport", bundle: .main)
            title = .getWord(by: "onboardingTitle2")
            subtitle = .getWord(by: "onboardingDescription3")
            buttonTitle = .getWord(by: "startUsage")
        case 3:
            UserDefaultsManager.shared.set(true, forKey: .isOnboarded)
        default:
            step = .zero
        }
    }
}

