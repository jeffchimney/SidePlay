//
//  ContentView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-08.
//

import SwiftUI
import CoreData
import AVKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var audioHandler: AudioHandler
    
    @State private var selectedPlaylist: Playlist? = nil

    var body: some View {
        NavigationView {
            if const.isIPad() {
                LibraryView(selectedPlaylist: $selectedPlaylist)
                    .environmentObject(audioHandler)
                    .environment(\.managedObjectContext, viewContext)
                
                if selectedPlaylist != nil {
                    PlaylistView(playlist: $selectedPlaylist)
                        .environmentObject(audioHandler)
                        .environment(\.managedObjectContext, viewContext)
                }

                if audioHandler.playlist != nil {
                    FullPlayerView()
                        .environmentObject(audioHandler)
                        .environment(\.managedObjectContext, viewContext)
                }
            } else {
                LibraryView(selectedPlaylist: $selectedPlaylist)
                    .environmentObject(audioHandler)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
        .accentColor(.buttonGradientStart)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
