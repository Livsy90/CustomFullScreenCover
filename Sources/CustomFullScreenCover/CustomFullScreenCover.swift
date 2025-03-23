import SwiftUI

public extension View {
    /// Presents a full-screen cover with a custom transition and animation.
    ///
    /// This method allows you to display a view as a full-screen cover with a specified transition effect and animation.
    /// Unlike the standard `fullScreenCover` modifier, this extension provides the flexibility to customize the transition
    /// (e.g., fade-in) and the animation timing.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to a Boolean value that determines whether the full-screen cover is presented.
    ///     When `true`, the cover is shown; when `false`, it is dismissed.
    ///   - transition: The transition effect to use when presenting and dismissing the cover. Defaults to `.opacity`
    ///     for a fade-in/fade-out effect.
    ///   - animation: The animation timing curve to apply to the transition. Defaults to `.easeInOut` for a smooth effect.
    ///   - content: A view builder that provides the content to be displayed in the full-screen cover.
    ///
    /// - Returns: A view that presents the specified content in a full-screen cover with the given transition and animation.
    ///
    /// - Note: This method uses a custom view modifier to manage the presentation logic, offering greater control over
    ///   the appearance and dismissal animations compared to the standard `fullScreenCover` modifier.
    ///
    /// **Example:**
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     @State private var isPresented = false
    ///
    ///     var body: some View {
    ///         Button("Show") {
    ///             isPresented = true
    ///         }
    ///         .buttonStyle(.borderedProminent)
    ///         .tint(.purple)
    ///         .shadow(radius: 2)
    ///         .frame(maxWidth: .infinity, maxHeight: .infinity)
    ///         .background(.orange)
    ///         .customFullScreenCover(isPresented: $isPresented, transition: .slide) {
    ///             ChildView(isPresented: $isPresented)
    ///         }
    ///   }
    /// }
    ///
    /// struct ChildView: View {
    ///   @Binding var isPresented: Bool
    ///
    ///   var body: some View {
    ///     VStack {
    ///       Button("Dismiss") {
    ///           isPresented = false
    ///       }
    ///       .buttonStyle(.borderedProminent)
    ///       .tint(.orange)
    ///       .shadow(radius: 2)
    ///       .frame(maxWidth: .infinity, maxHeight: .infinity)
    ///       .background(.purple)
    ///     }
    ///   }
    /// }
    ///  ```
    func customFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        transition: AnyTransition = .opacity,
        animation: Animation = .easeInOut,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        
        modifier(
            CustomFullScreenCoverModifier(
                isPresented: isPresented,
                transition: transition,
                animation: animation,
                presentedView: content
            )
        )
    }

    func popableModal<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        
        modifier(
            PopableModal(
                isPresented: isPresented,
                presentedView: content
            )
        )
    }
}

private struct CustomFullScreenCoverModifier<PresentedView: View>: ViewModifier {
    @Binding var isPresented: Bool
    let transition: AnyTransition
    let animation: Animation
    @ViewBuilder let presentedView: () -> PresentedView

    @State private var isPresentedInternal = false
    @State private var isShowContent = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var isActive = true

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresentedInternal) {
                Group {
                    if isShowContent {
                        presentedView()
                            .transition(transition)
                            .onDisappear {
                                guard isActive else { return }
                                isPresentedInternal = false
                                isPresented = false
                            }
                    }
                }
                .onAppear {
                    isShowContent = true
                }
                .presentationBackground(.clear)
            }
            .transaction {
                $0.disablesAnimations = true
                $0.animation = animation
            }
            .onChange(of: isPresented) { _, newValue in
                if newValue {
                    isPresentedInternal = true
                } else {
                    isShowContent = false
                }
            }
            .onChange(of: scenePhase) { _, newValue in
                switch newValue {
                case .background, .inactive:
                    isActive = false
                case .active:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isActive = true
                    }
                @unknown default:
                    break
                }
            }
    }
}

private struct PopableModal<PresentedView: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State private var offset: CGSize = .zero
    @ViewBuilder let presentedView: () -> PresentedView
    
    func body(content: Content) -> some View {
        content
            .customFullScreenCover(
                isPresented: $isPresented,
                transition: .move(edge: .trailing).combined(with: .opacity)
            ) {
                presentedView()
                    .compositingGroup()
                    .shadow(radius: 12)
                    .offset(offset)
                    .overlay(alignment: .leading) {
                        VStack {
                            Rectangle()
                                .fill(.clear)
                                .frame(height: 44)
                                .allowsHitTesting(false)
                            Color.clear
                                .contentShape(Rectangle())
                                .simultaneousGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if value.translation.width > 0 {
                                                withAnimation(.linear(duration: 0.1)) {
                                                    offset = CGSize(width: value.translation.width, height: 0)
                                                }
                                            }
                                        }
                                        .onEnded { value in
                                            if value.translation.width > 100 {
                                                withAnimation(.linear(duration: 0.1)) {
                                                    offset = CGSize(width: UIScreen.main.bounds.width, height: 0)
                                                }
                                                isPresented = false
                                                offset = .zero
                                            } else {
                                                withAnimation(.linear(duration: 0.1)) {
                                                    offset = .zero
                                                }
                                            }
                                        }
                                )
                                .allowsHitTesting(isPopGestureEnabled)
                        }
                        .frame(width: 16)
                    }
            }
    }
}
