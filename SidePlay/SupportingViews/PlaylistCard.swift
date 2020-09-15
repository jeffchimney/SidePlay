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
    @State var chosenColor: Color
    
    var colors: [Colors] = [
        Colors(color: Color.blueColor), Colors(color: Color.greenColor), Colors(color: Color.yellowColor), Colors(color: Color.redColor)
    ]
    
    @Binding var showAddPlayist: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            if !isEditing {
                playlist.colorForEnum
            } else {
                chosenColor
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
                                if chosenColor == .redColor {
                                    newPlaylist.color = ColorEnum.red.rawValue
                                } else if chosenColor == .yellowColor {
                                    newPlaylist.color = ColorEnum.yellow.rawValue
                                } else if chosenColor == .greenColor {
                                    newPlaylist.color = ColorEnum.green.rawValue
                                } else if chosenColor == .blueColor {
                                    newPlaylist.color = ColorEnum.blue.rawValue
                                } else {
                                    newPlaylist.color = ColorEnum.red.rawValue
                                }
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

                        HStack(spacing: 2) {
                            ForEach(self.colors) { color in
                                if color.color != chosenColor {
                                    Button {
                                        chosenColor = color.color
                                    } label: {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [color.color, color.color]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 25, height: 25)
                                    }
                                }
                            }
                        }
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

struct Colors: Identifiable {
    var id: UUID = UUID()
    var color: Color
}

struct PlaylistCard_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCard(playlist: Playlist(), chosenColor: Color.red, showAddPlayist: .constant(true))
    }
}
