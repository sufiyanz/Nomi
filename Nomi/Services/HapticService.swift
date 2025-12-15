import Foundation
import UIKit

// MARK: - Haptic Service

@MainActor
class HapticService {
    
    static let shared = HapticService()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    
    private init() {
        // Prepare generators for faster response
        prepareAll()
    }
    
    // MARK: - Public Methods
    
    /// Light impact - for subtle interactions
    func lightImpact() {
        guard Config.Features.enableHaptics else { return }
        impactLight.impactOccurred()
    }
    
    /// Medium impact - for standard interactions
    func mediumImpact() {
        guard Config.Features.enableHaptics else { return }
        impactMedium.impactOccurred()
    }
    
    /// Heavy impact - for significant interactions
    func heavyImpact() {
        guard Config.Features.enableHaptics else { return }
        impactHeavy.impactOccurred()
    }
    
    /// Selection changed - for picker/selection changes
    func selectionChanged() {
        guard Config.Features.enableHaptics else { return }
        selection.selectionChanged()
    }
    
    /// Success notification
    func success() {
        guard Config.Features.enableHaptics else { return }
        notification.notificationOccurred(.success)
    }
    
    /// Warning notification
    func warning() {
        guard Config.Features.enableHaptics else { return }
        notification.notificationOccurred(.warning)
    }
    
    /// Error notification
    func error() {
        guard Config.Features.enableHaptics else { return }
        notification.notificationOccurred(.error)
    }
    
    /// Prepare all generators
    func prepareAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selection.prepare()
        notification.prepare()
    }
}
