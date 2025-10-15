//
//  ContentView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import FirebaseAuth
import SwiftUI

struct ContentView: View {
  var userId: String

  var listManager: ListManager

  init(userId: String) {
    self.userId = userId
    self.listManager = ListManager(userId: self.userId)
  }

  var body: some View {
    if self.userId.isEmpty {
      AuthView()
    } else {
      MainView()
        .environmentObject(listManager)
    }
  }
}
