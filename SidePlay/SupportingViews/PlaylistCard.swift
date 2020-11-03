//
//  PlaylistCard.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-12.
//

import SwiftUI

struct PlaylistCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var audioHandler: AudioHandler
    
    var playlist: Playlist
    var isEditing: Bool = false
    @State private var newPlaylistName: String = ""
    
    @Binding var showAddPlayist: Bool
    @Binding var isEditingExistingPlaylist: Bool
    
    var body: some View {
        // Playlist Card
        NavigationLink(
            destination:
                PlaylistView(playlist: playlist)
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(audioHandler)) {
            HStack {
                if !isEditing {
                    AsyncImage(imageLastPathComponent: playlist.wrappedImageLastPathComponent)
                        .frame(width: 60, height: 60, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                } else {
                    AsyncImage(imageLastPathComponent: "")
                        .frame(width: 60, height: 60, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading) {
                    if !isEditing {
                        if isEditingExistingPlaylist {
                            TextField(playlist.wrappedName, text: $newPlaylistName) { (result) in }
                                onCommit: {
                                    playlist.name = newPlaylistName

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
                                .highPriorityGesture(TapGesture())
                                .foregroundColor(.primary)
                                .font(.headline)
                                .autocapitalization(UITextAutocapitalizationType.words)
                                .padding(.bottom, 5)
                        } else {
                            Text(playlist.wrappedName)
                                .font(.headline)
                                .fontWeight(.bold)
                                .lineLimit(2)
                                .padding(.bottom, 5)
                                .foregroundColor(.primary)
                        }
                        Text("Contains \(playlist.trackArray.count) items".uppercased())
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
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
                }
                .padding(.horizontal, 5)
                
                if isEditingExistingPlaylist {
                    Button(action: {
                        isEditingExistingPlaylist.toggle()
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.body)
                            .foregroundColor(.red)
                    })
                }
                
                Spacer()
            }
        }
    }
}

struct Colors: Identifiable {
    var id: UUID = UUID()
    var color: Color
}

struct PlaylistCard_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCard(playlist: Playlist(), showAddPlayist: .constant(true), isEditingExistingPlaylist: .constant(true))
    }
}
