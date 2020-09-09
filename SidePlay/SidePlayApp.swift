//
//  SidePlayApp.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-08.
//

import SwiftUI

@main
struct SidePlayApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
