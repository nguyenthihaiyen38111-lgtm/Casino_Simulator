import SwiftUI

@main
struct Casino_Simulator: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

struct AppRootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var didFinishLoading = false
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            if !didFinishLoading {
                LoadView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        didFinishLoading = true
                        showOnboarding = !hasSeenOnboarding
                    }
                }
                .transition(.opacity)
            } else if showOnboarding {
                OnboardingView {
                    hasSeenOnboarding = true
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showOnboarding = false
                    }
                }
                .transition(.opacity)
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
    }
}
