//
//  SidePlayApp.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-08.
//

import SwiftUI

enum ColorEnum: Int64 {
    case blue = 0
    case green = 1
    case yellow = 2
    case red = 3
}

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
