//
//  AuthViewModel.swift
//  dapa
//
//  Created by Youngchai Song on 2023/02/06.
//

import Foundation
import SwiftUI

// Apple Login
import CryptoKit
import AuthenticationServices

import Firebase
import GoogleSignIn


class AuthViewModel: ObservableObject {
    
    // MARK: View Properties
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    
    // MARK: Error PRoperties
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: Apple Sign Properties
    @Published var nonce: String = ""
    
    // MARK: App Log Status
    @AppStorage("log_status") var logStatus: Bool = false
    
    func checkIsLogined() {
        if Auth.auth().currentUser != nil {
            print("===== currentUser: \(Auth.auth().currentUser)")
        } else {
            print("Not logined")
        }
    }
    
    // MARK: - Firebase API's
    
    // MARK: Phone Number Login
    func getOTPCode() {
        
        UIApplication.shared.closeKeyboard()
        
        Task {
            do {
#if DEBUG
                // MARK: Disable it when testing with Real Device
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
#endif
                
                let code = try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(mobileNo)", uiDelegate: nil)
                await MainActor.run(body: {
                    CLIENT_CODE = code
                    // MARK: Enablind OTP Field When It's Success
                    withAnimation(.easeInOut) {
                        showOTPField = true
                    }
                })
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func verifyOTPCode() {
        
        UIApplication.shared.closeKeyboard()
        
        Task {
            do {
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_CODE, verificationCode: otpCode)
                
                try await Auth.auth().signIn(with: credential)
                
                // MARK: User Logged in Successfully
                print("Success!")
                await MainActor.run(body: {
                    withAnimation(.easeInOut) {
                        logStatus = true
                    }
                })
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    // MARK: Google Login
    
    
    // MARK: Apple Sign in API
    func appleAuthenticate(credential: ASAuthorizationAppleIDCredential) {
        
        // getting Token....
        guard let token = credential.identityToken else {
            print("Error With Firebase")
            return
        }
        
        // Token String...
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("Error With Token")
            return
        }
        
        
        
        Task {
            do {
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
                
                try await Auth.auth().signIn(with: credential)
                
                // MARK: User Logged in Successfully
                print("Success!")
                await MainActor.run(body: {
                    withAnimation(.easeInOut) {
                        logStatus = true
                    }
                })
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    // MARK: Logging Google User into Firebase
    func logGoogleUser(user: GIDGoogleUser) {
        Task {
            do {
                guard let idToken = user.idToken?.tokenString else { return }
                let accessToken = user.accessToken.tokenString
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                
                try await Auth.auth().signIn(with: credential)
                
                print("Success Google Login")
                
                await MainActor.run(body: {
                    withAnimation(.easeInOut) {
                        logStatus = true
                    }
                })
                
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    // MARK: Handling Error
    func handleError(error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
}

// helpers for Apple Login With Firebase...
func sha256(_ input: String) -> String {
  let inputData = Data(input.utf8)
  let hashedData = SHA256.hash(data: inputData)
  let hashString = hashedData.compactMap {
    String(format: "%02x", $0)
  }.joined()

  return hashString
}

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError(
                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                )
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}
