//
//  RewardsView.swift
//  dash
//
//  Displays user rewards and unlockable colors
//

import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var listManager: ListManager
    @StateObject private var rewardsManager = RewardsManager()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress to Next Reward
                    if let nextReward = rewardsManager.getNextReward() {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Next Milestone")
                                    .font(.system(size: 17, weight: .semibold))
                                Spacer()
                                Text("\(rewardsManager.getItemsToNext()) to go")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.gray)
                            }

                            // Progress Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 12)

                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color("purple"), Color("purple").opacity(0.6)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: geometry.size.width * rewardsManager.getProgressToNext(), height: 12)
                                }
                            }
                            .frame(height: 12)

                            HStack {
                                Image(systemName: nextReward.icon)
                                    .foregroundColor(Color("purple"))
                                Text(nextReward.title)
                                    .font(.system(size: 15, weight: .medium))
                                Spacer()
                                Text("\(nextReward.requiredItems) items")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .padding(.horizontal)
                    } else {
                        // All rewards unlocked
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            Text("All Rewards Unlocked!")
                                .font(.system(size: 17, weight: .semibold))
                            Text("You're a legend! 🎉")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }

                    // Rewards List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Rewards")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal)

                        ForEach(rewardsManager.rewards) { reward in
                            RewardRow(
                                reward: reward,
                                isUnlocked: rewardsManager.totalItemsCreated >= reward.requiredItems,
                                currentItems: rewardsManager.totalItemsCreated
                            )
                        }
                    }

                    // Unlocked Colors Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Unlocked Colors")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(rewardsManager.rewards) { reward in
                                ColorCard(
                                    colorName: reward.unlockedColor,
                                    displayName: reward.colorDisplayName,
                                    isUnlocked: rewardsManager.totalItemsCreated >= reward.requiredItems
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("You're crushing it! 🔥")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Rewards")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
        .onAppear {
            rewardsManager.fetchUserItemCount(from: listManager)
        }
    }
}

// MARK: - Reward Row Component

struct RewardRow: View {
    let reward: Reward
    let isUnlocked: Bool
    let currentItems: Int

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color("purple").opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)

                Image(systemName: reward.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isUnlocked ? Color("purple") : .gray)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(reward.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isUnlocked ? .primary : .gray)

                Text(reward.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                if isUnlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Text("Unlocked")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()

            // Lock/Unlock indicator
            if isUnlocked {
                Image(systemName: "lock.open.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isUnlocked ? Color("purple").opacity(0.05) : Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isUnlocked ? Color("purple").opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Color Card Component

struct ColorCard: View {
    let colorName: String
    let displayName: String
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: isUnlocked ? [Color(colorName), Color(colorName).opacity(0.6)] : [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 100)

                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
            }

            Text(displayName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isUnlocked ? .primary : .gray)
        }
    }
}

struct RewardsView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsView()
            .environmentObject(ListManager(userId: "preview"))
    }
}
