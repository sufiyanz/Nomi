import SwiftUI

// MARK: - Floating Animation

struct FloatingModifier: ViewModifier {
    @State private var isAnimating = false
    var amplitude: CGFloat = 8
    var duration: Double = 3.0
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: isAnimating ? -amplitude : amplitude)
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

extension View {
    func floating(amplitude: CGFloat = 8, duration: Double = 3.0, delay: Double = 0) -> some View {
        modifier(FloatingModifier(amplitude: amplitude, duration: duration, delay: delay))
    }
}

// MARK: - Scale Appear Animation

struct ScaleAppearModifier: ViewModifier {
    @State private var isShowing = false
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isShowing ? 1 : 0.5)
            .opacity(isShowing ? 1 : 0)
            .animation(
                Theme.Animation.bouncy.delay(delay),
                value: isShowing
            )
            .onAppear {
                isShowing = true
            }
    }
}

extension View {
    func scaleAppear(delay: Double = 0) -> some View {
        modifier(ScaleAppearModifier(delay: delay))
    }
}

// MARK: - Slide Up Animation

struct SlideUpModifier: ViewModifier {
    @State private var isShowing = false
    var offset: CGFloat = 50
    var delay: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: isShowing ? 0 : offset)
            .opacity(isShowing ? 1 : 0)
            .animation(
                Theme.Animation.spring.delay(delay),
                value: isShowing
            )
            .onAppear {
                isShowing = true
            }
    }
}

extension View {
    func slideUp(offset: CGFloat = 50, delay: Double = 0) -> some View {
        modifier(SlideUpModifier(offset: offset, delay: delay))
    }
}

// MARK: - Pulse Animation

struct PulseModifier: ViewModifier {
    @State private var isPulsing = false
    var minScale: CGFloat = 0.95
    var maxScale: CGFloat = 1.05
    var duration: Double = 1.5
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? maxScale : minScale)
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    func pulse(minScale: CGFloat = 0.95, maxScale: CGFloat = 1.05, duration: Double = 1.5) -> some View {
        modifier(PulseModifier(minScale: minScale, maxScale: maxScale, duration: duration))
    }
}

// MARK: - Shake Animation

struct ShakeModifier: ViewModifier {
    @Binding var trigger: Bool
    var amount: CGFloat = 10
    var shakesPerUnit: Int = 3
    
    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(amount: trigger ? amount : 0, shakesPerUnit: shakesPerUnit))
            .animation(Theme.Animation.quick, value: trigger)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        trigger = false
                    }
                }
            }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat
    var shakesPerUnit: Int
    var animatableData: CGFloat {
        get { amount }
        set { amount = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(CGFloat(shakesPerUnit) * .pi * amount),
            y: 0
        ))
    }
}

extension View {
    func shake(trigger: Binding<Bool>, amount: CGFloat = 10) -> some View {
        modifier(ShakeModifier(trigger: trigger, amount: amount))
    }
}

// MARK: - Card Flip Animation

struct CardFlipModifier: ViewModifier {
    @Binding var isFlipped: Bool
    var frontView: AnyView
    var backView: AnyView
    
    func body(content: Content) -> some View {
        ZStack {
            frontView
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 0 : 1)
            
            backView
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                .opacity(isFlipped ? 1 : 0)
        }
        .animation(Theme.Animation.standard, value: isFlipped)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        Circle()
            .fill(Theme.Colors.primaryFallback)
            .frame(width: 50, height: 50)
            .floating()
        
        Circle()
            .fill(Theme.Colors.primaryFallback)
            .frame(width: 50, height: 50)
            .floating(amplitude: 12, duration: 2.5, delay: 0.5)
        
        RoundedRectangle(cornerRadius: 12)
            .fill(Theme.Colors.primaryFallback)
            .frame(width: 100, height: 60)
            .scaleAppear()
        
        Text("Slide Up")
            .foregroundColor(.white)
            .slideUp()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Theme.Colors.backgroundFallback)
}
