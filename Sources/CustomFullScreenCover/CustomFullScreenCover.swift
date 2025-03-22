import SwiftUI

public extension View {
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
}

private struct CustomFullScreenCoverModifier<PresentedView: View>: ViewModifier {
    @Binding var isPresented: Bool
    let transition: AnyTransition
    let animation: Animation
    @ViewBuilder let presentedView: () -> PresentedView

    @State private var isPresentedInternal = false
    @State private var isShowContent = false

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresentedInternal) {
                Group {
                    if isShowContent {
                        presentedView()
                            .transition(transition)
                            .onDisappear {
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
    }
}
