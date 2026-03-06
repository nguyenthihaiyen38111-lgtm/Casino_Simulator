// Path: Shared/View+PresentationDetents.swift

import SwiftUI

extension View {
    @ViewBuilder
    func applyMediumDetentIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents([.medium])
        } else {
            self
        }
    }
}
