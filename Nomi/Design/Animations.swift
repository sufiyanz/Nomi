//
//  Animations.swift
//  Nomi
//
//  Created on December 7, 2025.
//

import SwiftUI

// MARK: - Custom Animations
extension Animation {
    static let nomiBounce = Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)
    static let nomiSoft = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
    static let nomiQuick = Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    static let nomiSlow = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
    
    static func nomiDelay(_ delay: Double) -> Animation {
        Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0).delay(delay)
    }
}

// MARK: - View Modifiers for Animations

// Button style that allows scrolling (use this for buttons inside ScrollView)
struct BouncePressStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.nomiBounce, value: configuration.isPressed)
    }
}

// Legacy BouncePress for non-scrollable contexts (use sparingly)
struct BouncePress: ViewModifier {
    @State private var isPressed = false
    var scale: CGFloat = 0.95
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(.nomiBounce, value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

struct FloatingAnimation: ViewModifier {
    @State private var isFloating = false
    var amplitude: CGFloat = 5
    var duration: Double = 2
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -amplitude : amplitude)
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                isFloating = true
            }
    }
}

struct WiggleAnimation: ViewModifier {
    @State private var isWiggling = false
    var angle: Double = 3
    var duration: Double = 0.15
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(isWiggling ? angle : -angle))
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: isWiggling
            )
            .onAppear {
                isWiggling = true
            }
    }
}

struct PopIn: ViewModifier {
    @State private var isVisible = false
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1 : 0)
            .opacity(isVisible ? 1 : 0)
            .animation(.nomiBounce.delay(delay), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
}

struct SlideIn: ViewModifier {
    @State private var isVisible = false
    var direction: Edge = .bottom
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: offsetX,
                y: offsetY
            )
            .opacity(isVisible ? 1 : 0)
            .animation(.nomiSoft.delay(delay), value: isVisible)
            .onAppear {
                isVisible = true
            }
    }
    
    private var offsetX: CGFloat {
        guard !isVisible else { return 0 }
        switch direction {
        case .leading: return -50
        case .trailing: return 50
        default: return 0
        }
    }
    
    private var offsetY: CGFloat {
        guard !isVisible else { return 0 }
        switch direction {
        case .top: return -50
        case .bottom: return 50
        default: return 0
        }
    }
}

// MARK: - View Extensions
extension View {
    func bouncePress(scale: CGFloat = 0.95) -> some View {
        modifier(BouncePress(scale: scale))
    }
    
    func floating(amplitude: CGFloat = 5, duration: Double = 2) -> some View {
        modifier(FloatingAnimation(amplitude: amplitude, duration: duration))
    }
    
    func wiggle(angle: Double = 3, duration: Double = 0.15) -> some View {
        modifier(WiggleAnimation(angle: angle, duration: duration))
    }
    
    func popIn(delay: Double = 0) -> some View {
        modifier(PopIn(delay: delay))
    }
    
    func slideIn(from direction: Edge = .bottom, delay: Double = 0) -> some View {
        modifier(SlideIn(direction: direction, delay: delay))
    }
}

// MARK: - Flip Card Animation
struct FlipEffect: GeometryEffect {
    var angle: Double
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let a = CGFloat(Angle(degrees: angle).radians)
        var transform3d = CATransform3DIdentity
        transform3d.m34 = -1/500
        transform3d = CATransform3DRotate(transform3d, a, 0, 1, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width/2, -size.height/2, 0)
        
        let affineTransform = ProjectionTransform(CGAffineTransform(
            a: transform3d.m11,
            b: transform3d.m12,
            c: transform3d.m21,
            d: transform3d.m22,
            tx: transform3d.m41 + size.width/2,
            ty: transform3d.m42 + size.height/2
        ))
        
        return affineTransform
    }
}

extension View {
    func flip(angle: Double) -> some View {
        modifier(FlipModifier(angle: angle))
    }
}

struct FlipModifier: ViewModifier {
    var angle: Double
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(angle),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
    }
}
