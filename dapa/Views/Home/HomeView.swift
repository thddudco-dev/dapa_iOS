//
//  HomeView.swift
//  dapa
//
//  Created by Youngchai Song on 2023/02/06.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct HomeView: View {
    
    @AppStorage("log_status") var logStatus: Bool = false
    
    var body: some View {
        
        NavigationView {
            Text("Logged In")
                .navigationTitle("Multi-Login")
                .toolbar {
                    ToolbarItem {
                        Button("Logout") {
                            try? Auth.auth().signOut()
                            GIDSignIn.sharedInstance.signOut()
                            withAnimation {
                                logStatus = false
                            }
                        }
                    }
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
