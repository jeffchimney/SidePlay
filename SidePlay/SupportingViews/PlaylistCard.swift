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
    @State private var offsetDirection: OffsetDirection = .center
    @State private var newPlaylistName: String = ""
    @State private var offset = CGSize.zero
    @State private var swipeLeftShouldStick = false
    @State private var swipeRightShouldStick = false
    
    var colors: [Colors] = [
        Colors(color: Color.blueColor), Colors(color: Color.greenColor), Colors(color: Color.yellowColor), Colors(color: Color.redColor)
    ]
    
    @Binding var showAddPlayist: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Play  / edit delete playlist buttons under playlist card
            HStack {
                // play button to continue listening to playlist
                Button(action: {
                    // play
                }, label: {
                    Image(systemName: "play.circle.fill")
                        .imageScale(.medium)
                        .font(.headline)
                        .foregroundColor(.buttonGradientEnd)
                })
                .opacity(offsetDirection == .right ? 1 : 0)
                .transition(.move(edge: .leading))
                .padding()
                Spacer()
                
                // Edit Playlist button
                Button(action: {
                    // play
                }, label: {
                    Image(systemName: "pencil.circle")
                        .imageScale(.medium)
                        .font(.body)
                        .foregroundColor(.buttonGradientStart)
                })
                .opacity(offsetDirection == .left ? 1 : 0)
                .transition(.move(edge: .trailing))
                .padding()
                
                // Delete Playlist button
                Button(action: {
                    // play
                }, label: {
                    Image(systemName: "trash")
                        .imageScale(.medium)
                        .font(.headline)
                        .foregroundColor(.red)
                })
                .opacity(offsetDirection == .left ? 1 : 0)
                .transition(.move(edge: .trailing))
                .padding()
            }
            
            // Playlist Card
            HStack {
                if !isEditing {
//                        Image(uiImage: UIImage(data: playlist.wrappedImage)!)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 25, height: 25, alignment: .center)
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
                        Text(playlist.wrappedName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(2)
                            .padding(.bottom, 5)
                            .foregroundColor(.primary)
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
                            }, label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.body)
                                    .foregroundColor(.red)
                            })
                        }
                    }
                }
                .padding(.horizontal, 5)
 
                Spacer()
            }
            .background(Color.backgroundColor)
            .offset(x: offset.width, y: 0)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        self.offset = gesture.translation
                        
                        if gesture.translation.width <= -30 {
                            swipeLeftShouldStick = true
                            swipeRightShouldStick = false
                        }
                        
                        if gesture.translation.width >= 30 {
                            swipeLeftShouldStick = false
                            swipeRightShouldStick = true
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            if swipeLeftShouldStick {
                                if offsetDirection == .right {
                                    self.offset = CGSize(width: .zero, height: offset.height)
                                    self.offsetDirection = .center
                                } else {
                                    self.offset = CGSize(width: -100, height: offset.height)
                                    self.offsetDirection = .left
                                }
                            } else if swipeRightShouldStick {
                                if offsetDirection == .left {
                                    self.offset = CGSize(width: .zero, height: offset.height)
                                    self.offsetDirection = .center
                                } else {
                                    self.offset = CGSize(width: 50, height: offset.height)
                                    self.offsetDirection = .right
                                }
                            }
                        }
                    }
            )
        }
    }
}

struct Colors: Identifiable {
    var id: UUID = UUID()
    var color: Color
}

enum OffsetDirection {
    case left
    case center
    case right
}

struct PlaylistCard_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCard(playlist: Playlist(), showAddPlayist: .constant(true))
    }
}
