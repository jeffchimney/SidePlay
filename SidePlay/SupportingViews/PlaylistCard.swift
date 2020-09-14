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
    
    var playlist: Playlist
    var isEditing: Bool = false
    
    @State var newPlaylistName: String = ""
    
    @Binding var showAddPlayist: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            if !isEditing {
                playlist.colorForEnum
            } else {
                Color.yellowColor
            }

            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.white, .white]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    if !isEditing {
                        Image(uiImage: UIImage(data: playlist.wrappedImage)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .center)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25, alignment: .center)
                    }
                }
                .frame(width: 70, height: 70, alignment: .center)
                
                
                VStack(alignment: .leading) {
                    if !isEditing {
                        Text(playlist.wrappedName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(2)
                            .padding(.bottom, 5)
                            .foregroundColor(.white)
                        Text("Contains \(playlist.trackArray.count) items".uppercased())
                            .font(.caption)
                            .foregroundColor(.white)
                    } else {                        
                        TextField("New Playlist", text: $newPlaylistName) { (result) in }
                            onCommit: {
                                let newPlaylist = Playlist(context: viewContext)
                                newPlaylist.name = newPlaylistName
                                newPlaylist.color = ColorEnum.yellow.rawValue
                                newPlaylist.image = UIImage(systemName: "photo")!.pngData()
                                newPlaylist.favorite = false
                                
                                do {
                                    try viewContext.save()
                                } catch {
                                    let nsError = error as NSError
                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                }
                                
                                showAddPlayist = false
                            }
                        .foregroundColor(.white)
                        .font(.headline)
                        .autocapitalization(UITextAutocapitalizationType.words)
                        .padding(.bottom, 5)

                    }
                }
                .padding(.horizontal, 5)
 
                Spacer()
            }
            .padding(15)
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct PlaylistCard_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCard(playlist: Playlist(), showAddPlayist: .constant(true))
    }
}
