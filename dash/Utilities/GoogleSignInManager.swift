//
//  GoogleSignInManager.swift
//  dash
//
//  Created by Gergo Csizmadia on 2025. 11. 05.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import OSLog
import SwiftUI

class GoogleSignInManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    func signInWithGoogle(completion: @escaping (Result<String, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase Client ID"])
            AppLogger.auth.error("Google Sign-In: Missing Firebase Client ID")
            completion(.failure(error))
            return
        }

        AppLogger.auth.info("Initiating Google Sign-In")

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
                    // If the user cancelled the Google sign-in flow, do not treat it as an error
                    let nsError = error as NSError
                    if nsError.code == GIDSignInError.canceled.rawValue {
                        AppLogger.auth.debug("Google Sign-In cancelled by user")
                        return
                    }

                    AppLogger.auth.error("Google Sign-In failed: \(error.localizedDescription)")
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
                        AppLogger.auth.error("Google Sign-In Firebase auth failed: \(error.localizedDescription)")
                        self.errorMessage = error.localizedDescription
                        completion(.failure(error))
                        return
                    }

                    if let uid = authResult?.user.uid {
                        AppLogger.auth.notice("Google Sign-In successful")
                        completion(.success(uid))
                    } else {
                        let error = NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])
                        AppLogger.auth.error("Google Sign-In failed to get user ID")
                        self.errorMessage = error.localizedDescription
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
