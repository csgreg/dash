//
//  DeepLinkHandler.swift
//  dash
//
//  Handles deep link parsing and navigation
//

import Foundation

enum DeepLink: Equatable {
    case joinList(listId: String)
    case none
}

class DeepLinkHandler: ObservableObject {
    @Published var activeDeepLink: DeepLink = .none

    func handleURL(_ url: URL) {
        // Handle universal link: https://www.justdashapp.com/join/{listId}
        let pathComponents = url.pathComponents

        if pathComponents.count >= 3, pathComponents[1] == "join" {
            let listId = pathComponents[2]
            activeDeepLink = .joinList(listId: listId)
        }
    }

    func reset() {
        activeDeepLink = .none
    }

    static func generateShareURL(for listId: String) -> URL? {
        return URL(string: "https://www.justdashapp.com/join/\(listId)")
    }
}
