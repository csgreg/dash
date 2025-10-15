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
  @State var listName: String = ""
  @State var showAlert: Bool = false
  @State var alertMessage: String = ""

  @EnvironmentObject var listManager: ListManager

  private var isValidInput: Bool {
    if case .success = InputValidator.validateListName(listName) {
      return true
    }
    return false
  }

  var body: some View {
    NavigationView {
      ZStack {
        VStack(alignment: .leading) {
          Text(
            "Craft customized lists for any purpose, share a unique code for seamless collaboration."
          )
          .font(.subheadline)
          .padding(.trailing)
          .padding(.leading)
          .foregroundColor(Color("dark-gray"))
          Spacer()
          HStack {
            Image(systemName: "list.bullet.clipboard.fill")
            TextField("List name", text: $listName).preferredColorScheme(.light)

            Spacer()

            if !listName.isEmpty {
              Image(systemName: isValidInput ? "checkmark" : "xmark")
                .fontWeight(.bold)
                .foregroundColor(isValidInput ? .green : .red)
            }
          }
          .foregroundColor(Color("purple"))
          .padding()
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(lineWidth: 2)
              .foregroundColor(Color("purple"))
          )
          .padding()
          Spacer()
          Spacer()
          Button(action: {
            listManager.createList(listName: self.listName) { (message) in
              self.alertMessage = message
              self.showAlert = true
            }
          }) {
            Text("Create")
              .foregroundColor(.white)
              .font(.title3)
              .bold()
              .frame(maxWidth: .infinity)
              .padding()
              .background(
                .linearGradient(
                  colors: [Color("purple").opacity(1), Color("purple").opacity(0.5)],
                  startPoint: .topLeading, endPoint: .bottomTrailing)
              )
              .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
              .padding(.vertical)
          }
          .disabled(!isValidInput)
          .opacity(isValidInput ? 1.0: 0.6)
          .padding(.horizontal)
          .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage))
          }
        }
        .frame(
          minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity,
          alignment: .topLeading)
      }.navigationTitle("Create new list")
    }
  }
}

struct CreateView_Previews: PreviewProvider {
  static var previews: some View {
    CreateView()
      .environmentObject(ListManager(userId: "asd"))
  }
}
