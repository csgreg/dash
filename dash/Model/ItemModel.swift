//
//  ItemModel.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 18.
//

import Foundation

/// Represents an item in a list with completion status
struct Item: Identifiable, Encodable {
    enum Kind: String, Encodable {
        case task
        case header
    }

    var id: String
    var text: String
    var done: Bool = false
    var order: Int = 0
    var kind: Kind = .task
}
