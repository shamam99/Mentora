//
//  NavigationUtil.swift
//  Mentora
//
//  Created by Shamam Alkafri on 18/05/2025.
//


import SwiftUI

enum NavigationUtil {
    static func popToRootView() {
        findNavigationController(viewController: UIApplication.shared.windows.first?.rootViewController)?
            .popToRootViewController(animated: true)
    }

    private static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        if let nav = viewController as? UINavigationController {
            return nav
        }
        for child in viewController?.children ?? [] {
            if let nav = findNavigationController(viewController: child) {
                return nav
            }
        }
        return nil
    }
}
