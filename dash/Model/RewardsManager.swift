//
//  RewardsManager.swift
//  dash
//
//  Manages user achievements and unlockable rewards
//

import Foundation
import SwiftUI

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requiredItems: Int
    let unlockedColor: String
    let colorDisplayName: String
}

class RewardsManager: ObservableObject {
    @Published var totalItemsCreated: Int = 0

    // Achievement tiers with unlockable colors
    let achievements: [Achievement] = [
        Achievement(
            id: "earlybird",
            title: "Early Bird",
            description: "Create your first 100 items",
            icon: "sunrise.fill",
            requiredItems: 0,
            unlockedColor: "purple",
            colorDisplayName: "Purple"
        ),
        Achievement(
            id: "taskmaster",
            title: "Task Master",
            description: "Create 100 items",
            icon: "star.fill",
            requiredItems: 100,
            unlockedColor: "blue",
            colorDisplayName: "Blue"
        ),
        Achievement(
            id: "productivity-pro",
            title: "Productivity Pro",
            description: "Create 500 items",
            icon: "bolt.fill",
            requiredItems: 500,
            unlockedColor: "green",
            colorDisplayName: "Green"
        ),
        Achievement(
            id: "legendary",
            title: "Legendary",
            description: "Create 1,000 items",
            icon: "crown.fill",
            requiredItems: 1000,
            unlockedColor: "orange",
            colorDisplayName: "Orange"
        ),
        Achievement(
            id: "ultimate",
            title: "Ultimate Champion",
            description: "Create 2,500+ items",
            icon: "trophy.fill",
            requiredItems: 2500,
            unlockedColor: "pink",
            colorDisplayName: "Pink"
        ),
    ]

    // Get current achievement tier
    func getCurrentAchievement() -> Achievement {
        return achievements.last(where: { totalItemsCreated >= $0.requiredItems }) ?? achievements[0]
    }

    // Get next achievement to unlock
    func getNextAchievement() -> Achievement? {
        return achievements.first(where: { totalItemsCreated < $0.requiredItems })
    }

    // Get all unlocked colors
    func getUnlockedColors() -> [String] {
        return achievements
            .filter { totalItemsCreated >= $0.requiredItems }
            .map { $0.unlockedColor }
    }

    // Check if a color is unlocked
    func isColorUnlocked(_ colorName: String) -> Bool {
        return getUnlockedColors().contains(colorName)
    }

    // Get progress to next achievement (0.0 to 1.0)
    func getProgressToNext() -> Double {
        guard let next = getNextAchievement() else {
            return 1.0 // All achievements unlocked
        }

        let current = getCurrentAchievement()
        let range = Double(next.requiredItems - current.requiredItems)
        let progress = Double(totalItemsCreated - current.requiredItems)

        return min(max(progress / range, 0.0), 1.0)
    }

    // Get items remaining to next achievement
    func getItemsToNext() -> Int {
        guard let next = getNextAchievement() else {
            return 0
        }
        return next.requiredItems - totalItemsCreated
    }

    // Fetch total created items from user document
    func fetchUserItemCount(from listManager: ListManager) {
        listManager.fetchUserItemCount { count in
            DispatchQueue.main.async {
                self.totalItemsCreated = count
            }
        }
    }
}
