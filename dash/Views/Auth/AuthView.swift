//
//  AuthView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import SwiftUI

struct AuthView: View {
  @State private var currentViewShowing: String = "login"

  var body: some View {
    if currentViewShowing == "login" {
      LoginView(currentShowingView: $currentViewShowing)
        .preferredColorScheme(.light)
        .transition(.move(edge: .leading))
    } else {
      SignupView(currentShowingView: $currentViewShowing)
        .preferredColorScheme(.light)
    }
  }
}

struct AuthView_Previews: PreviewProvider {
  static var previews: some View {
    AuthView()
  }
}
