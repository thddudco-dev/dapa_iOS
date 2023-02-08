//
//  ContentView.swift
//  dapa
//
//  Created by Youngchai Song on 2023/02/03.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @AppStorage("log_status") var logStatus: Bool = false
    
    var body: some View {
        if logStatus {
            HomeView()
        } else {
            AuthView()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
