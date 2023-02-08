//
//  KakaoSignInAuthenticator.swift
//  dapa
//
//  Created by Youngchai Song on 2023/02/06.
//

import Foundation

final class KakaoSignInAuthenticator: ObservableObject {
    
    private var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
      self.authViewModel = authViewModel
    }
    
    func signIn() {
        
    }
    
    func signOut() {
        
    }
    
    func disconnect() {
        
    }
}
