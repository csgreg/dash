//
//  SignupView.swift
//  dash
//
//  Created by Gergo Csizmadia on 2023. 03. 12.
//

import SwiftUI
import FirebaseAuth

struct SignupView: View {
    @Binding var currentShowingView: String
    @AppStorage("uid") var userID: String = ""
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var verifyPassword: String = ""
    @State private var signUpFail = false
    @State private var failTitle = ""
    @State private var loading: Bool = false
    
    var body: some View {
        ZStack{
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack{
                HStack{
                    Text("Create an account!")
                        .foregroundColor(.white)
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
                    TextField("", text: $email, prompt: Text("Email").foregroundColor(.white.opacity(0.6)))
                        .autocapitalization(.none)
                        
                    
                    Spacer()
                    
                    if(email.count != 0){
                        Image(systemName: email.isValidEmail() ? "checkmark" : "xmark")
                            .fontWeight(.bold)
                            .foregroundColor(email.isValidEmail() ? .green : .red)
     
                    }
                }
                .foregroundColor(.white)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                )
                .padding(.horizontal)
                .padding(.bottom)
                
                //password
                HStack {
                    Image(systemName: "lock")
                    SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white.opacity(0.6)))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    if(password.count != 0){
                        Image(systemName: password.isValidPassword() ? "checkmark" : "xmark")
                            .fontWeight(.bold)
                            .foregroundColor(password.isValidPassword() ? .green : .red)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                )
                .padding(.horizontal)
                .padding(.bottom)
                
                //password confirm
                HStack {
                    Image(systemName: "lock")
                    SecureField("", text: $verifyPassword, prompt: Text("Verify Password").foregroundColor(.white.opacity(0.6)))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    if(verifyPassword.count != 0){
                        Image(systemName: verifyPassword.isValidPassword() ? "checkmark" : "xmark")
                            .fontWeight(.bold)
                            .foregroundColor(verifyPassword.isValidPassword() ? .green : .red)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.white)
                )
                .padding(.horizontal)
                .padding(.bottom)

                
                //sign in button
                Button(action: {
                    withAnimation{
                        self.currentShowingView = "login"
                    }
                }){
                    Text("Have an account? Sign in!")
                        .foregroundColor(.white.opacity(0.9))
                }
                
                
                Spacer()
                Spacer()
                
                //sign in button
                Button(action: {
                    loading = true
                    if(!email.isValidEmail()){
                        signUpFail = true
                        failTitle = "Please type a correct email address!"
                        loading = false
                        return
                    }
                    if(!password.isValidPassword()){
                        signUpFail = true
                        failTitle = "Password must be at least 8 characters long!"
                        loading = false
                        return
                    }
                    if(password != verifyPassword){
                        signUpFail = true
                        failTitle = "Passwords do not match. Please try again."
                        loading = false
                        return
                    }

                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        if error != nil {
                            signUpFail = true
                            failTitle = "Please try again later or check your internet connection!"
                            loading = false
                            return
                        }
                        
                        if let authResult = authResult{
                            withAnimation{
                                userID = authResult.user.uid
                            }
                        }
                        loading = false
                    }
                }){
                    Text("Create Account")
                        .foregroundColor(.black)
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                        )
                        .padding(.horizontal)
                }
                .disabled(loading)
                .alert(isPresented: $signUpFail) {
                    Alert(
                        title: Text("Failed to sign up"),
                        message: Text(failTitle)
                    )
                }
                .padding(.bottom)
            }
        }
    }
}
