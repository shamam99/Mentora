//
//  MentoraApp.swift
//  Mentora
//
//  Created by Shamam Alkafri on 03/05/2025.
//


import SwiftUI

@main
struct MentoraApp: App {
    @StateObject private var gameCenterManager = GameCenterManager.shared

    var body: some Scene {
        WindowGroup {
            AuthView()
                .environmentObject(gameCenterManager)
        }
    }
}
