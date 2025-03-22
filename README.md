# A full-screen cover with a custom transition and animation.

This modifier allows you to display a view as a full-screen cover with a specified transition effect and animation.
Unlike the standard `fullScreenCover` modifier, this extension allows you to customize the transition (e.g., fade-in) and the animation timing.

## Example: 

```swift
struct ContentView: View {
    @State private var isPresented = false
    
    let animation: Animation = .bouncy
    let transition: AnyTransition = .asymmetric(
        insertion: .opacity,
        removal: .scale.combined(with: .opacity)
    )
    
    var body: some View {
        Button("Show") {
            isPresented = true
        }
        .buttonStyle(.borderedProminent)
        .tint(.purple)
        .shadow(radius: 2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.orange)
        .customFullScreenCover(
            isPresented: $isPresented,
            transition: transition,
            animation: animation
        ) {
            FullScreenView(isPresented: $isPresented)
        }
    }
}

struct FullScreenView: View {
  @Binding var isPresented: Bool

  var body: some View {
    VStack {
      Button("Dismiss") {
          isPresented = false
      }
      .buttonStyle(.borderedProminent)
      .tint(.orange)
      .shadow(radius: 2)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.purple)
    }
  }
}

#Preview {
    ContentView()
}
```

<img src="https://github.com/Livsy90/CustomFullScreenCover/blob/main/demo2.gif" width ="300">

<img src="https://github.com/Livsy90/CustomFullScreenCover/blob/main/demo1.gif" width ="300">

<img src="https://github.com/Livsy90/CustomFullScreenCover/blob/main/demo3.gif" width ="300">
