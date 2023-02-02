//
//  dapaApp.swift
//  dapa
//
//  Created by Youngchai Song on 2023/02/03.
//

import SwiftUI

@main
struct dapaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
