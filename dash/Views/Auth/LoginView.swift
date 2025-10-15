//
//  LoginView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import SwiftUI
import FirebaseAuth
import RiveRuntime

struct LoginView: View {
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var signInFail: Bool = false
    @State private var loading: Bool = false
    
    
    var body: some View {
        ZStack{
            RiveViewModel(fileName: "shapes").view()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .blur(radius: 40)
                
            
            VStack{
                HStack{
                    Text("Welcome back!")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
                .padding()
                .padding(.top)
                
                Spacer()
                
                //email input
                HStack {
                    Image(systemName: "mail")
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                    
                    Spacer()
                    
                    if(email.count != 0){
                        Image(systemName: email.isValidEmail() ? "checkmark" : "xmark")
                            .fontWeight(.bold)
                            .foregroundColor(email.isValidEmail() ? .green : .red)
     
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.black)
                )
                .padding(.bottom)
                .padding(.horizontal)
                
                //password
                HStack {
                    Image(systemName: "lock")
                    SecureField("Password", text: $password)
                    
                    Spacer()
                    
                    if(password.count != 0){
                        Image(systemName: password.isValidPassword() ? "checkmark" : "xmark")
                            .fontWeight(.bold)
                            .foregroundColor(password.isValidPassword() ? .green : .red)
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.black)
                )
                .padding(.bottom)
                .padding(.horizontal)
                
                //create account button
                Button(action: {
                    withAnimation{
                        self.currentShowingView = "signup"
                    }
                }){
                    Text("New here? Sign up!")
                        .foregroundColor(.black.opacity(0.7))
                }
                
                Spacer()
                Spacer()
                
                //sign in button
                    Button(action: {
                        loading=true
                        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                            if error != nil {
                                signInFail = true
                            }
                            
                            if let authResult = authResult {
                                withAnimation {
                                    userID = authResult.user.uid
                                }
                            }
                            loading = false
                        }
                    }){
                        Text("Sign In")
                            .foregroundColor(.white)
                            .font(.title3)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.black)
                            )
                            .padding(.horizontal)
                    }
                    .disabled(loading)
                    .alert(isPresented: $signInFail) {
                        Alert(
                            title: Text("Failed to log in"),
                            message: Text("Oops! Incorrect email or password.")
                        )
                    }
                    .padding(.bottom)
            }
        }
    }
}
