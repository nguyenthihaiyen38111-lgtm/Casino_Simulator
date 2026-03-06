// Path: Profile/ProfileAvatarStore.swift

import Foundation
import SwiftUI
import UIKit
import Combine

@MainActor
final class ProfileAvatarStore: ObservableObject {
    static let shared = ProfileAvatarStore()

    @Published private(set) var image: UIImage?

    private let storageKey = "projectx.profile.avatar.jpeg.v1"

    private init() {
        load()
    }

    func setImage(_ newImage: UIImage) {
        image = newImage
        save(newImage)
    }

    func removeImage() {
        image = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        image = UIImage(data: data)
    }

    private func save(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.88) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
