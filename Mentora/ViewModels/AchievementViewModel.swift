//
//  AchievementViewModel.swift
//  Mentora
//
//  Created by Shamam Alkafri on 19/05/2025.
//


import Foundation
import GameKit

final class AchievementsViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var currentStreak: Int
    

    init(streak: Int = 1) {
        self.currentStreak = streak
        loadAchievements()
    }

    /// Loads achievements from backend first, fallback to GameKit if it fails
    func loadAchievements() {
        APIManager.shared.fetchAchievements { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let badges):
                    self.achievements = badges

                    // ✅ Auto-report unlocked achievements
                    for badge in badges where badge.isUnlocked {
                        self.reportAchievement(id: badge.id)
                    }

                case .failure(let error):
                    print("Failed to load from backend, fallback to GameKit. Error:", error)
                    self.loadGameCenterBackup()
                }
            }
        }

    }

    /// Fallback loader that queries Game Center directly
    private func loadGameCenterBackup() {
        let baseList: [Achievement] = [
            Achievement(id: "badge1", title: "The fifth star !", description: "Answering 5 questions in a row", iconName: "offStar", isUnlocked: false),
            Achievement(id: "badge2", title: "King of the game !", description: "Creating 3 games", iconName: "offStar", isUnlocked: false),
            Achievement(id: "badge3", title: "Popular Kid !", description: "Added more than 5 friends", iconName: "offStar", isUnlocked: false),
            Achievement(id: "badge4", title: "Educated king !", description: "Uploaded 4 different files", iconName: "offStar", isUnlocked: false)
        ]

        GKAchievement.loadAchievements { earned, error in
            if let error = error {
                print("Failed to load Game Center achievements: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.achievements = baseList
                }
                return
            }

            let unlockedIDs = earned?.filter { $0.isCompleted }.map { $0.identifier } ?? []

            DispatchQueue.main.async {
                self.achievements = baseList.map { item in
                    var updated = item
                    if unlockedIDs.contains(item.id) {
                        updated.isUnlocked = true
                        updated.iconName = "lightStar"
                    }
                    return updated
                }
            }
        }
    }

    /// Sends progress to Game Center manually
    func reportAchievement(id: String) {
        let achievement = GKAchievement(identifier: id)
        achievement.percentComplete = 100
        achievement.showsCompletionBanner = true
        GKAchievement.report([achievement], withCompletionHandler: nil)
    }

    /// Marks and reports an achievement locally and to Game Center
    func unlockAchievement(id: String) {
        if let index = achievements.firstIndex(where: { $0.id == id && !$0.isUnlocked }) {
            reportAchievement(id: id)
            achievements[index].isUnlocked = true
            achievements[index].iconName = "lightStar"
        }
    }
}
