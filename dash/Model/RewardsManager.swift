//
//  RewardsManager.swift
//  dash
//
//  Manages user rewards and unlockable colors
//

import Foundation
import OSLog
import SwiftUI

struct Reward: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requiredItems: Int
    let unlockedColor: String
    let colorDisplayName: String
}

class RewardsManager: ObservableObject {
    @Published var totalItemsCreated: Int = 0 {
        didSet {
            checkForNewRewards(oldValue: oldValue)
        }
    }

    private var unlockedRewards: Set<String> = []

    // Reward tiers with unlockable colors
    let rewards: [Reward] = [
        Reward(
            id: "starter",
            title: "Purple Theme",
            description: "Available from the start",
            icon: "paintbrush.fill",
            requiredItems: 0,
            unlockedColor: "purple",
            colorDisplayName: "Purple"
        ),
        Reward(
            id: "red-unlock",
            title: "Red Theme",
            description: "Unlock at 100 items",
            icon: "paintpalette.fill",
            requiredItems: 100,
            unlockedColor: "red",
            colorDisplayName: "Red"
        ),
        Reward(
            id: "blue-unlock",
            title: "Blue Theme",
            description: "Unlock at 500 items",
            icon: "sparkles",
            requiredItems: 500,
            unlockedColor: "blue",
            colorDisplayName: "Blue"
        ),
        Reward(
            id: "orange-unlock",
            title: "Orange Theme",
            description: "Unlock at 1000 items",
            icon: "gift.fill",
            requiredItems: 1000,
            unlockedColor: "orange",
            colorDisplayName: "Orange"
        ),
    ]

    // Get current reward tier
    func getCurrentReward() -> Reward {
        return rewards.last(where: { totalItemsCreated >= $0.requiredItems }) ?? rewards[0]
    }

    // Get next reward to unlock
    func getNextReward() -> Reward? {
        return rewards.first(where: { totalItemsCreated < $0.requiredItems })
    }

    // Get all unlocked colors
    func getUnlockedColors() -> [String] {
        return rewards
            .filter { totalItemsCreated >= $0.requiredItems }
            .map { $0.unlockedColor }
    }

    // Check if a color is unlocked
    func isColorUnlocked(_ colorName: String) -> Bool {
        return getUnlockedColors().contains(colorName)
    }

    // Get progress to next reward (0.0 to 1.0)
    func getProgressToNext() -> Double {
        guard let next = getNextReward() else {
            return 1.0 // All rewards unlocked
        }

        let current = getCurrentReward()
        let range = Double(next.requiredItems - current.requiredItems)
        let progress = Double(totalItemsCreated - current.requiredItems)

        return min(max(progress / range, 0.0), 1.0)
    }

    // Get items remaining to next reward
    func getItemsToNext() -> Int {
        guard let next = getNextReward() else {
            return 0
        }
        return next.requiredItems - totalItemsCreated
    }

    // Fetch total created items from user document
    func fetchUserItemCount(from listManager: ListManager) {
        AppLogger.rewards.debug("Fetching user item count for rewards")
        listManager.fetchUserItemCount { count in
            DispatchQueue.main.async {
                self.totalItemsCreated = count
                AppLogger.rewards.info("Item count loaded: \(count, privacy: .public)")
            }
        }
    }

    // Check if user unlocked new rewards
    private func checkForNewRewards(oldValue: Int) {
        let previousReward = rewards.last(where: { oldValue >= $0.requiredItems })
        let currentReward = rewards.last(where: { totalItemsCreated >= $0.requiredItems })

        // Check if we crossed into a new reward tier
        if let current = currentReward,
           previousReward?.id != current.id,
           !unlockedRewards.contains(current.id)
        {
            unlockedRewards.insert(current.id)
            AppLogger.rewards.notice("Reward unlocked: \(current.title, privacy: .public) - \(current.colorDisplayName, privacy: .public) color")
        }
    }
}
