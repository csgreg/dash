//
//  CreateView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 20.
//

import FirebaseCore
import FirebaseFirestore
import SwiftUI

struct CreateView: View {
    @Binding var selectedTab: Int

    @State var listName: String = ""
    @State var selectedEmoji: String?
    @State var selectedColor: String? = "purple" // Auto-select first color
    @State var showErrorAlert: Bool = false
    @State var errorMessage: String = ""
    @State var showEmojiModal: Bool = false
    @State var showColorModal: Bool = false

    @EnvironmentObject var listManager: ListManager
    @EnvironmentObject private var rewardsManager: RewardsManager
    @Environment(\.colorScheme) private var colorScheme

    private var isValidInput: Bool {
        if case .success = InputValidator.validateListName(listName) {
            return true
        }
        return false
    }

    private func performCreate() {
        listManager.createList(
            listName: listName, emoji: selectedEmoji, color: selectedColor
        ) { success, message in
            if success {
                self.listName = ""
                self.selectedEmoji = nil
                self.selectedColor = "purple"
                selectedTab = 0
            } else {
                self.errorMessage = message
                self.showErrorAlert = true
            }
        }
    }

    private var createButton: some View {
        Button(action: {
            performCreate()
        }) {
            createButtonLabel
        }
        .modifier(GlassEffectIfAvailable())
        .disabled(!isValidInput)
        .opacity(isValidInput ? 1.0 : 0.5)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private var createButtonInline: some View {
        Button(action: {
            performCreate()
        }) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                Text("Create")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(buttonGradient)
            .cornerRadius(.infinity)
            .shadow(color: Color("purple").opacity(0.25), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .modifier(GlassEffectIfAvailable())
        .disabled(!isValidInput)
        .opacity(isValidInput ? 1.0 : 0.5)
    }

    private var createButtonLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 20, weight: .bold))
            Text("Create List")
                .font(.system(size: 18, weight: .bold))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(buttonGradient)
        .cornerRadius(.infinity)
        .shadow(color: Color("purple").opacity(0.3), radius: 12, x: 0, y: 6)
    }

    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [Color("purple").opacity(1), Color("purple").opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var formScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                createHeader
                styleHintCard
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 40)
            }
        }
    }

    private var styleHintCard: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.18))
                Image(systemName: "paintbrush.pointed.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 6) {
                Text("Make it now. Remix it later.")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                Text("You can update your list anytime in its settings. Go full neon. Go minimal. Your list, your vibe.")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: "gearshape.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.92))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(buttonGradient)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color("purple").opacity(0.25), radius: 14, x: 0, y: 10)
        .padding(.horizontal, 16)
    }

    private var createHeader: some View {
        let curveDepth: CGFloat = 0
        let cornerRadius: CGFloat = 28
        let shape = CreateHeaderShape(curveDepth: curveDepth, cornerRadius: cornerRadius)
        let quickPicks = [
            "Groceries",
            "Travel",
            "Work",
        ]
        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Create a new list")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("Name it, pick an emoji and color, and start organizing in seconds.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                ZStack {
                    Circle()
                        .fill(Color("purple").opacity(colorScheme == .dark ? 0.22 : 0.12))
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("purple"))
                }
                .frame(width: 44, height: 44)
            }

            Text("Quick picks")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                ForEach(quickPicks, id: \.self) { title in
                    quickPickChip(title: title)
                }
            }

            Divider()
                .opacity(0.18)

            listNameSection
            customizationSection

            createButtonInline
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.top, 22)
        .padding(.bottom, 28)
        .background(colorScheme == .dark ? Color(.secondarySystemBackground) : Color.white)
        .clipShape(shape)
        .overlay(
            shape
                .strokeBorder(
                    colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06), lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.08), radius: 16, x: 0, y: 10)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func quickPickChip(title: String) -> some View {
        Button {
            listName = title
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .truncationMode(.tail)
                .fixedSize(horizontal: true, vertical: false)
                .foregroundColor(colorScheme == .dark ? Color.primary : Color.black.opacity(0.75))
                .padding(.vertical, 6)
                .padding(.horizontal, 9)
                .background(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.06))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var listNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("List Name")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Image(systemName: "pencil.line")
                    .foregroundColor(.primary)
                    .font(.system(size: 16, weight: .semibold))

                TextField("Enter list name", text: $listName)
                    .font(.system(size: 16, weight: .medium))

                if !listName.isEmpty {
                    Image(systemName: isValidInput ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isValidInput ? .green : .red)
                        .padding(.trailing, 2)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(colorScheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.06), lineWidth: 1)
            )
        }
    }

    private var customizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Customize")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button(action: {
                    withAnimation {
                        showEmojiModal = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(buttonGradient)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                            )

                        if let emoji = selectedEmoji {
                            Text(emoji)
                                .font(.system(size: 26))
                        } else {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 56, height: 56)
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)

                Button(action: {
                    withAnimation {
                        showColorModal = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(selectedColor ?? "purple"))
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.primary.opacity(colorScheme == .dark ? 0.18 : 0.10), lineWidth: 1)
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(Color("purple").opacity(0.35), lineWidth: 3)
                                    .opacity((selectedColor ?? "purple") == "purple" ? 0 : 0.0)
                            )

                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(width: 56, height: 56)
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                formScrollView
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("Create list")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
            .overlay(
                Group {
                    if showEmojiModal {
                        EmojiSelectorModal(selectedEmoji: $selectedEmoji, isPresented: $showEmojiModal)
                            .transition(.opacity)
                    }
                }
            )
            .overlay(
                Group {
                    if showColorModal {
                        ColorSelectorModal(
                            selectedColor: $selectedColor, isPresented: $showColorModal,
                            rewardsManager: rewardsManager
                        )
                        .transition(.opacity)
                    }
                }
            )
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}

private struct CreateHeaderShape: InsettableShape {
    var curveDepth: CGFloat
    var cornerRadius: CGFloat
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> some InsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        var path = Path()

        let curve = max(0, min(curveDepth, rect.height / 2))
        let effectiveHeight = max(0, rect.height - curve)
        let radius = min(cornerRadius, min(rect.width / 2, effectiveHeight / 2))
        let bottomY = rect.maxY - curve

        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: bottomY - radius))
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: bottomY - radius),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        if curve > 0 {
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + radius, y: bottomY),
                control: CGPoint(x: rect.midX, y: rect.maxY)
            )
        } else {
            path.addLine(to: CGPoint(x: rect.minX + radius, y: bottomY))
        }

        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: bottomY - radius),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Emoji Selector Button Component

struct EmojiSelectorButton: View {
    let selectedEmoji: String?
    @Binding var showModal: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                showModal = true
            }
        }) {
            HStack(spacing: 12) {
                // Emoji preview or placeholder
                if let emoji = selectedEmoji {
                    Text(emoji)
                        .font(.system(size: 24))
                } else {
                    ZStack {
                        Text("😊")
                            .font(.system(size: 20))
                            .opacity(0.5)
                    }
                }

                Text(selectedEmoji == nil ? "Select emoji" : "Change emoji")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("dark-gray"))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("purple").opacity(0.5))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .modifier(GlassEffectIfAvailable())
        }
    }
}

// MARK: - Color Selector Button Component

struct ColorSelectorButton: View {
    let selectedColor: String?
    @Binding var showModal: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                showModal = true
            }
        }) {
            HStack(spacing: 12) {
                // Color preview
                if let colorName = selectedColor {
                    Circle()
                        .fill(Color(colorName))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(0.2), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                }

                Text("Change color")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("dark-gray"))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("purple").opacity(0.5))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .modifier(GlassEffectIfAvailable())
        }
    }
}

// MARK: - Preview

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView(selectedTab: .constant(1))
            .environmentObject(ListManager(userId: "asd"))
    }
}
