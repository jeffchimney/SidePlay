//
//  PlaylistCard.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-12.
//

import SwiftUI

struct NewPlaylistCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var audioHandler: AudioHandler
    
    var playlist: Playlist
    @State private var newPlaylistName: String = ""
    
    @Binding var showAddPlayist: Bool
    
    var body: some View {
        HStack {
            AsyncImage(imageLastPathComponent: "")
                .frame(width: 60, height: 60, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading) {
                HStack {
                    TextField("New Playlist", text: $newPlaylistName) { (result) in }
                        onCommit: {
                            let newPlaylist = Playlist(context: viewContext)
                            newPlaylist.name = newPlaylistName
                            newPlaylist.imageLastPathComponent = ""
                            newPlaylist.favorite = false
                            
                            self.showAddPlayist = false
                            if audioHandler.isPlaying {
                                audioHandler.isShowingPlayer = true
                            }
                            
                            do {
                                try viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                        .foregroundColor(.primary)
                        .font(.headline)
                        .autocapitalization(UITextAutocapitalizationType.words)
                        .padding(.bottom, 5)
                    Button(action: {
                        showAddPlayist.toggle()
                        if audioHandler.isPlaying {
                            audioHandler.isShowingPlayer = true
                        }
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .foregroundColor(.red)
                    })
                }
            }
            .padding(.horizontal, 5)
            
            Spacer()
        }
    }
}

struct NewPlaylistCard_Previews: PreviewProvider {
    static var previews: some View {
        NewPlaylistCard(playlist: Playlist(), showAddPlayist: .constant(true))
    }
}
