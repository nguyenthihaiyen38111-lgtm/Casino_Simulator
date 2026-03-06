//
//  Casino_Simulator.swift
//

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
    @State private var showMainContent = false

    var body: some View {
        ZStack {
            if showMainContent {
                ContentView()
                    .transition(.opacity)
            } else {
                LoadView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showMainContent = true
                    }
                }
                .transition(.opacity)
            }
        }
    }
}
