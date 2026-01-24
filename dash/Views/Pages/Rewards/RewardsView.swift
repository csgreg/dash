//
//  RewardsView.swift
//  dash
//
//  Displays user rewards and unlockable colors
//

import SwiftUI

struct RewardsView: View {
    @EnvironmentObject private var rewardsManager: RewardsManager

    private var headerCard: some View {
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Rewards")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(currentRewardSubtitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                pointsPill
            }

            currentRewardRow

            if let nextReward = rewardsManager.getNextReward() {
                nextMilestoneSection(nextReward: nextReward)
            } else {
                allUnlockedSection
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
        .padding(.bottom, 24)
        .dashCardStyle(shape)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var currentRewardSubtitle: String {
        if rewardsManager.getNextReward() == nil {
            return "Everything unlocked. Absolute legend."
        }
        return "Keep going — new themes unlock as you create items."
    }

    private var pointsPill: some View {
        HStack(spacing: 8) {
            Image(systemName: "trophy.fill")
                .foregroundColor(Color("purple"))
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(rewardsManager.totalItemsCreated)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                Text("Points")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.black.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private var currentRewardRow: some View {
        let current = rewardsManager.getCurrentReward()
        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color("purple").opacity(0.16))
                Image(systemName: current.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("purple"))
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 2) {
                Text("Current")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                Text(current.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
            }

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                Circle()
                    .fill(Color(current.unlockedColor))
                    .frame(width: 10, height: 10)
                Text(current.colorDisplayName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }

    private func nextMilestoneSection(nextReward: Reward) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Next Milestone")
                    .font(.system(size: 15, weight: .semibold))
                Spacer(minLength: 0)
                Text("\(rewardsManager.getItemsToNext()) to go")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.08))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color("purple"), Color("purple").opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * rewardsManager.getProgressToNext(),
                            height: 12
                        )
                }
            }
            .frame(height: 12)

            HStack {
                Image(systemName: nextReward.icon)
                    .foregroundColor(Color("purple"))
                Text(nextReward.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer(minLength: 0)
                Text("\(nextReward.requiredItems) items")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 4)
    }

    private var allUnlockedSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text("All rewards unlocked")
                    .font(.system(size: 15, weight: .bold))
                Text("You’ve unlocked every theme.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 4)
    }

    private var rewardsListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Milestones")
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
    }

    private var unlockedColorsSection: some View {
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
    }

    private var contentCard: some View {
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
        return VStack(spacing: 32) {
            rewardsListSection

            Divider()
                .padding(.horizontal)

            unlockedColorsSection
        }
        .padding(.top, 24)
        .padding(.bottom, 24)
        .dashCardStyle(shape)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerCard
                    contentCard
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("Rewards")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
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
                            colors: isUnlocked
                                ? [Color(colorName), Color(colorName).opacity(0.6)]
                                : [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
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
            .environmentObject(RewardsManager(userId: "preview"))
    }
}
