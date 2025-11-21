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
        // Handle custom URL scheme: dash://join/{listId}
        // Or universal link: https://yourdomain.com/join/{listId}

        if url.scheme == "dash" {
            handleCustomScheme(url)
        } else if url.scheme == "https" || url.scheme == "http" {
            handleUniversalLink(url)
        }
    }

    private func handleCustomScheme(_ url: URL) {
        // Expected format: dash://join/{listId}
        let path = url.host ?? ""

        if path == "join" {
            let listId = url.pathComponents.last ?? ""
            if !listId.isEmpty, listId != "/" {
                activeDeepLink = .joinList(listId: listId)
                return
            }
        }

        // Alternative format: dash://join?listId={listId}
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems,
           let listId = queryItems.first(where: { $0.name == "listId" })?.value
        {
            activeDeepLink = .joinList(listId: listId)
            return
        }
    }

    private func handleUniversalLink(_ url: URL) {
        let pathComponents = url.pathComponents

        if pathComponents.count >= 3, pathComponents[1] == "join" {
            let listId = pathComponents[2]
            activeDeepLink = .joinList(listId: listId)
        }
    }

    func reset() {
        activeDeepLink = .none
    }

    static func generateShareURL(for listId: String, useUniversalLink: Bool = false) -> URL? {
        if useUniversalLink {
            // This requires setting up Apple App Site Association file
            return URL(string: "https://www.justdashapp.com/join/\(listId)")
        } else {
            // Custom URL scheme (works immediately, no server setup needed)
            return URL(string: "dash://join/\(listId)")
        }
    }
}
