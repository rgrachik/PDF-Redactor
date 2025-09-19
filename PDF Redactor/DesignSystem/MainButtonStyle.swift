//
//  MainButtonStyle.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 17.09.2025.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    
    // MARK: - Constants
    
    private enum Constants {
        static let opacity: CGFloat = 0.8
        static let cornerRadius: CGFloat = 16
        static let animationDuration: Double = 0.2
        static let scaleEffectValue: Double = 0.98
        static let scaleEffectDefautlValue: Double = 0.98
    }
    
    // MARK: - Properties
    
    var fillColor: Color
    
    // MARK: - Func
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? fillColor.opacity(Constants.opacity) : fillColor)
            .foregroundColor(.white)
            .cornerRadius(Constants.cornerRadius)
            .scaleEffect(configuration.isPressed ? Constants.scaleEffectValue : Constants.scaleEffectDefautlValue)
            .animation(.easeOut(duration: Constants.animationDuration), value: configuration.isPressed)
    }
}
