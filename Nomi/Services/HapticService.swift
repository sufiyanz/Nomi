//
//  HapticService.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import Foundation
import UIKit

@MainActor
final class HapticService {
    static let shared = HapticService()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators for immediate response
        prepareGenerators()
    }
    
    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selection.prepare()
        notification.prepare()
    }
    
    // MARK: - Impact Feedback
    
    func lightImpact() {
        impactLight.impactOccurred()
        impactLight.prepare()
    }
    
    func mediumImpact() {
        impactMedium.impactOccurred()
        impactMedium.prepare()
    }
    
    func heavyImpact() {
        impactHeavy.impactOccurred()
        impactHeavy.prepare()
    }
    
    // MARK: - Selection Feedback
    
    func selectionChanged() {
        selection.selectionChanged()
        selection.prepare()
    }
    
    // MARK: - Notification Feedback
    
    func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }
    
    func warning() {
        notification.notificationOccurred(.warning)
        notification.prepare()
    }
    
    func error() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }
    
    // MARK: - Custom Patterns
    
    /// Bouncy collection feedback - used when adding a sticker
    func collect() {
        mediumImpact()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.lightImpact()
        }
    }
    
    /// Flip card feedback
    func flip() {
        lightImpact()
    }
    
    /// Correct answer feedback
    func correct() {
        success()
    }
    
    /// Wrong answer feedback  
    func incorrect() {
        warning()
    }
    
    /// Button tap feedback
    func tap() {
        lightImpact()
    }
}
