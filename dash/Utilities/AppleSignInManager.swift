import AuthenticationServices
import CryptoKit
import FirebaseAuth
import OSLog
import SwiftUI
import UIKit

class AppleSignInManager: NSObject, ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var currentNonce: String?
    private var completion: ((Result<String, Error>) -> Void)?

    func signInWithApple(completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion

        AppLogger.auth.info("Initiating Apple Sign-In")

        let nonce = randomNonceString()
        currentNonce = nonce

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        isLoading = true
        errorMessage = nil
        controller.performRequests()
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            var random: UInt8 = 0
            let error = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if error != errSecSuccess {
                continue
            }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }

        return result
    }
}

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller _: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let completion = completion else { return }

        isLoading = false

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            let error = NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid credential type"])
            errorMessage = error.localizedDescription
            completion(.failure(error))
            return
        }

        guard
            let nonce = currentNonce,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            let error = NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])
            errorMessage = error.localizedDescription
            completion(.failure(error))
            return
        }

        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                AppLogger.auth.error("Apple Sign-In Firebase auth failed: \(error.localizedDescription)")
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
                return
            }

            if let uid = authResult?.user.uid {
                AppLogger.auth.notice("Apple Sign-In successful")
                completion(.success(uid))
            } else {
                let error = NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user ID"])
                AppLogger.auth.error("Apple Sign-In failed to get user ID")
                self.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        }
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        isLoading = false

        // If the user cancelled the Apple sign-in sheet, do not treat it as an error
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            AppLogger.auth.debug("Apple Sign-In cancelled by user")
            return
        }

        AppLogger.auth.error("Apple Sign-In authorization failed: \(error.localizedDescription)")
        errorMessage = error.localizedDescription
        completion?(.failure(error))
    }
}

extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first
        {
            return window
        }

        return ASPresentationAnchor()
    }
}
