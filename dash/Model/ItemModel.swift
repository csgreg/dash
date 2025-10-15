//
//  ItemModel.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 18.
//

import Foundation

/// Represents an item in a list with completion status
struct Item: Identifiable, Encodable {
    var id: String
    var text: String
    var done: Bool = false
    var order: Int = 0
}
