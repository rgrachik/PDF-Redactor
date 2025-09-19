//
//  OnboardingView.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 17.09.2025.
//

import SwiftUI

struct OnboardingView: View {
    
    // MARK: - Constants
    
    private enum Constants {
        static let vStackSpacing: CGFloat = 15.0
        static let scaleEffect: CGFloat = 0.7
        static let onboardingSlidesCount: Double = 3
        static let animationDuration: TimeInterval = 0.05
    }
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var isOnboardingPassed: Bool
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Constants.vStackSpacing) {
            
            Spacer()
            
            Image(viewModel.image)
                .scaleEffect(Constants.scaleEffect)
            
            Text(viewModel.title)
                .font(.title)
            
            Text(viewModel.subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            ProgressView(value: Double(viewModel.step) + 1, total: Constants.onboardingSlidesCount)
                .tint(viewModel.step < 2 ? .appBlue : .green)
                .animation(.easeInOut(duration: Constants.animationDuration), value: viewModel.step)
            
            Spacer()
            
            Button(viewModel.buttonTitle) {
                if viewModel.step < 2 {
                    viewModel.nextStep()
                } else {
                    isOnboardingPassed = true
                    UserDefaultsManager.shared.set(true, forKey: .isOnboarded)
                }
                
            }
            .buttonStyle(MainButtonStyle(fillColor: .appDarkBlue))
        }
        .padding()
        .foregroundStyle(.appBackground)
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel(), isOnboardingPassed: .constant(false))
}

