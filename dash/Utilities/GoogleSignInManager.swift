//
//  GoogleSignInManager.swift
//  dash
//
//  Created by Gergo Csizmadia on 2025. 11. 05.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import SwiftUI

class GoogleSignInManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    func signInWithGoogle(completion: @escaping (Result<String, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase Client ID"])
            completion(.failure(error))
            return
        }

        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Get the presenting view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController
        else {
            let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller"])
            completion(.failure(error))
            return
        }

        isLoading = true
        errorMessage = nil

        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }

                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString
                else {
                    let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user token"])
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)

                // Authenticate with Firebase
                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        completion(.failure(error))
                        return
                    }

                    if let uid = authResult?.user.uid {
                        completion(.success(uid))
                    } else {
                        let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])
                        self.errorMessage = error.localizedDescription
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
