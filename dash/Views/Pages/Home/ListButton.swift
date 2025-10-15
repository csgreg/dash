//
//  ListButton.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 18.
//

import SwiftUI

struct ListButton: View {
    var text: String = ""
    var allItems: Int = 3
    var completedItems: Int = 3
    var sharedWith: Int = 1

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(text)
                        .customFont(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack {
                        Image(systemName: sharedWith > 1 ? "lock.open" : "lock").foregroundColor(
                            .white.opacity(0.5))
                        Text(
                            sharedWith > 1
                                ? "Shared with \(sharedWith - 1) \(sharedWith - 1 > 1 ? "accounts" : "account")!"
                                : "Not shared!"
                        )
                        .customFont(.footnote).foregroundColor(.white.opacity(0.7))
                    }
                }
                Divider()
                VStack {
                    Text("\(allItems) \(allItems > 1 ? "items" : "item")")
                    if allItems > 0 {
                        Text("\(completedItems == allItems ? "All" : String(completedItems)) completed")
                            .customFont(.caption2)
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: 100)
            .foregroundColor(.white)
            .background(
                .linearGradient(
                    colors: [Color("purple").opacity(1), Color("purple").opacity(0.5)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color("purple").opacity(0.3), radius: 8, x: 0, y: 12)
            .shadow(color: Color("purple").opacity(0.3), radius: 2, x: 0, y: 1)
        }
    }
}

struct ListButton_Previews: PreviewProvider {
    static var previews: some View {
        ListButton(text: "Izgalmas lista ").background(.white)
    }
}
