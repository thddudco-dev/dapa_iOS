//
//  AuthView.swift
//  dapa
//
//  Created by Youngchai Song on 2023/02/06.
//

import SwiftUI
import AuthenticationServices

import GoogleSignIn
import GoogleSignInSwift
import Firebase

struct AuthView: View {
    
    @StateObject var authModel: AuthViewModel = .init()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                Image(systemName: "triangle")
                    .font(.system(size: 38))
                    .foregroundColor(.indigo)
                
                (Text("Welcom,")
                    .foregroundColor(.black) +
                Text("\nLogin to continue")
                    .foregroundColor(.gray))
                .font(.title)
                .fontWeight(.semibold)
                .lineSpacing(10)
                .padding(.top, 20)
                .padding(.trailing, 15)
                
                // MARK: Custom TextField
                CustomTextField(hint: "+1 65055551234", text: $authModel.mobileNo)
                    .disabled(authModel.showOTPField)
                    .opacity(authModel.showOTPField ? 0.4 : 1)
                    .overlay(alignment: .trailing, content: {
                        Button("Change") {
                            withAnimation(.easeInOut) {
                                authModel.showOTPField = false
                                authModel.otpCode = ""
                                authModel.CLIENT_CODE = ""
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.indigo)
                        .opacity(authModel.showOTPField ? 1 : 0)
                        .padding(.trailing, 15)
                        
                    })
                    .padding(.top, 50)
                
                CustomTextField(hint: "OTP Code", text: $authModel.otpCode)
                    .disabled(!authModel.showOTPField)
                    .opacity(!authModel.showOTPField ? 0.4 : 1)
                    .padding(.top, 20)
                
                Button {
                    authModel.showOTPField ? authModel.verifyOTPCode() : authModel.getOTPCode()
                } label: {
                    HStack(spacing: 15) {
                        Text(authModel.showOTPField ? "Verify Code" : "Get Code")
                            .fontWeight(.semibold)
//                            .contentTransition(.identity)
                        
                        Image(systemName: "line.diagonal.arrow")
                            .font(.title3)
                            .rotationEffect(.init(degrees: 45))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 25)
                    .padding(.vertical)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.black.opacity(0.05))
                    }
                }
                .padding(.top, 30)
                
                HStack(spacing: 8) {
                    
                    // MARK: Custom Apple Sign in Button
                    CustomButton()
                    .overlay {
                        // Apple Login Button
                        SignInWithAppleButton { request in
                            
                            // requesting parameters from apple login....
                            authModel.nonce = randomNonceString()
                            request.requestedScopes = [.email, .fullName]
                            request.nonce = sha256(authModel.nonce)
                            
                        } onCompletion: { result in
                            
                            // getting error or success
                            
                            switch result {
                            case .success(let user):
                                print("success")
                                guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                                    print("Erroe With Firebase")
                                    return
                                }
                                authModel.appleAuthenticate(credential: credential)
                            case .failure(let error):
                                print((error.localizedDescription))
                            }
                            
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 55)
                        .blendMode(.overlay)
                    }
                    .clipped()
                    
                    // MARK: Custom Google Sign in Button
                    CustomButton(isGoogle: true)
                    .overlay {
//                        if let clientID = FirebaseApp.app()?.options.clientID {
//                            
//                        }
//                        
                        GoogleSignInButton {
                            
                            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

                            // Create Google Sign In configuration object.
                            let config = GIDConfiguration(clientID: clientID)
                            
                            GIDSignIn.sharedInstance.configuration = config
                            
                            GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.rootController()) { user, error in
                                
                                if let error = error {
                                    print(error.localizedDescription)
                                }
                                
                                if let user = user?.user {
                                    authModel.logGoogleUser(user: user)
                                }
                                
                            }
                        }
                        .blendMode(.overlay)
                        
                    }
                    .clipped()
                    
                }
                .padding(.leading, -60)
                .frame(maxWidth: .infinity)
                
                
                
            }
            .padding(.leading, 60)
            .padding(.vertical, 15)
        }
        .alert(authModel.errorMessage, isPresented: $authModel.showError) {
            
        }
        .onAppear(perform: {
            authModel.checkIsLogined()
        })
            
    }
    
    @ViewBuilder
    func CustomButton(isGoogle: Bool = false) -> some View {
        HStack {
            Group {
                if isGoogle {
                    Image("Google")
                        .resizable()
                        .renderingMode(.template)
                } else {
                    Image(systemName: "applelogo")
                        .resizable()
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .frame(height: 45)
            
                
            Text("\(isGoogle ? "Google" : "Apple") Sign in")
                .font(.callout)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 25)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
