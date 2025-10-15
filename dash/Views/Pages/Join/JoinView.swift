//
//  JoinView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 20.
//

import FirebaseCore
import FirebaseFirestore
import SwiftUI

struct JoinView: View {
  @State var listCode: String = ""
  @State var alertMessage: String = ""
  @State var showAlert: Bool = false

  @AppStorage("uid") var userID: String = ""

  @EnvironmentObject var listManager: ListManager

  private var isValidInput: Bool {
    if case .success = InputValidator.validateListCode(listCode) {
      return true
    }
    return false
  }

  var body: some View {
    NavigationView {
      ZStack {
        Color.white.edgesIgnoringSafeArea(.all)
        VStack(alignment: .leading) {
          Text(
            "Enter a code to join existing lists. Collaborate on tasks, events, or shopping effortlessly with friends and family."
          )
          .font(.subheadline)
          .padding(.trailing)
          .padding(.leading)
          .foregroundColor(Color("dark-gray"))
          Spacer()
          HStack {
            Image(systemName: "list.bullet.clipboard.fill")
            TextField("Code", text: $listCode).preferredColorScheme(.light)

            Spacer()

            if !listCode.isEmpty {
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
            listManager.joinToList(listId: self.listCode, userId: userID) { (message) in
              self.alertMessage = message
              self.showAlert = true
            }
          }) {
            Text("Join")
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
              .padding(.horizontal)
          }
          .disabled(!isValidInput)
          .opacity(isValidInput ? 1.0: 0.6)
          .padding(.vertical)
          .alert(isPresented: $showAlert) {
            Alert(
              title: Text(alertMessage)
            )
          }
        }
        .frame(
          minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity,
          alignment: .topLeading)
      }.navigationTitle("Join the Collaboration")
    }
  }
}

struct JoinView_Previews: PreviewProvider {
  static var previews: some View {
    JoinView()
      .environmentObject(ListManager(userId: "asd"))
  }
}
