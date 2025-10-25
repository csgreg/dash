//
//  RewardsView.swift
//  dash
//
//  Displays user achievements and unlockable colors
//

import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var listManager: ListManager
    @StateObject private var rewardsManager = RewardsManager()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Stats Section
                    VStack(spacing: 12) {
                        Image(systemName: rewardsManager.getCurrentAchievement().icon)
                            .font(.system(size: 60))
                            .foregroundColor(Color("purple"))

                        Text("\(rewardsManager.totalItemsCreated)")
                            .font(.system(size: 48, weight: .bold))

                        Text("Items Created")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.gray)

                        Text(rewardsManager.getCurrentAchievement().title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("purple"))
                    }
                    .padding(.top, 20)

                    // Progress to Next Achievement
                    if let nextAchievement = rewardsManager.getNextAchievement() {
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
                                Image(systemName: nextAchievement.icon)
                                    .foregroundColor(Color("purple"))
                                Text(nextAchievement.title)
                                    .font(.system(size: 15, weight: .medium))
                                Spacer()
                                Text("\(nextAchievement.requiredItems) items")
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
                        // All achievements unlocked
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            Text("All Achievements Unlocked!")
                                .font(.system(size: 17, weight: .semibold))
                            Text("You're a legend! 🎉")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }

                    // Achievements List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Achievements")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal)

                        ForEach(rewardsManager.achievements) { achievement in
                            AchievementRow(
                                achievement: achievement,
                                isUnlocked: rewardsManager.totalItemsCreated >= achievement.requiredItems,
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
                            ForEach(rewardsManager.achievements) { achievement in
                                ColorCard(
                                    colorName: achievement.unlockedColor,
                                    displayName: achievement.colorDisplayName,
                                    isUnlocked: rewardsManager.totalItemsCreated >= achievement.requiredItems
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Rewards 🏆")
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

// MARK: - Achievement Row Component

struct AchievementRow: View {
    let achievement: Achievement
    let isUnlocked: Bool
    let currentItems: Int

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color("purple").opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)

                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isUnlocked ? Color("purple") : .gray)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isUnlocked ? .primary : .gray)

                Text(achievement.description)
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
