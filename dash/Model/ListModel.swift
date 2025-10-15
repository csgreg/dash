//
//  ListModel.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 18.
//

import Foundation

/// Represents a shared list containing items and users
struct Listy: Identifiable {
  var id: String
  var name: String
  var items: [Item]
  var users: [String]
}
