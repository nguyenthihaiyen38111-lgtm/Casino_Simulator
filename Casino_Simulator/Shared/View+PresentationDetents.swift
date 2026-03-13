// Path: Shared/View+PresentationDetents.swift
//Developer Chuong Nguyen

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
