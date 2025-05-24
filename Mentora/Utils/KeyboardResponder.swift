//
//  KeyboardResponder.swift
//  Mentora
//
//  Created by Shamam Alkafri on 19/05/2025.
//

import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0

    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .sink { notification in
                withAnimation(.easeOut(duration: 0.25)) {
                    self.currentHeight = KeyboardResponder.keyboardHeight(from: notification)
                }
            }
    }

    deinit {
        cancellable?.cancel()
    }

    private static func keyboardHeight(from notification: Notification) -> CGFloat {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return 0
        }

        return frame.height >= UIScreen.main.bounds.height ? 0 : frame.height
    }
}
