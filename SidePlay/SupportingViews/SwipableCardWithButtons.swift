//
//  PlaylistCard.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-12.
//

import SwiftUI

struct SwipableCardWithButtons: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var audioHandler: AudioHandler
    
    var playlist: Playlist
    var isEditing: Bool = false
    @State private var offsetDirection: OffsetDirection = .center
    @State private var newPlaylistName: String = ""
    @State private var offset = CGSize.zero
    @State private var navigationIsActive = true
    @State private var swipeLeftShouldStick = false
    @State private var swipeRightShouldStick = false
    
    @Binding var showAddPlayist: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Play  / edit delete playlist buttons under playlist card
            HStack {
                // play button to continue listening to playlist
                Button(action: {
                    // play
                    print("play button pushed")
                }, label: {
                    Image(systemName: "play.circle.fill")
                        .imageScale(.medium)
                        .font(.headline)
                        .foregroundColor(.buttonGradientEnd)
                })
                .highPriorityGesture(TapGesture())
                .opacity(offsetDirection == .right ? 1 : 0)
                .transition(.move(edge: .leading))
                .padding()
                Spacer()
                
                // Edit Playlist button
                Button(action: {
                    // edit
                    print("edit button pushed")
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
                    // delete
                    print("delete button pushed")
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
            PlaylistCard(playlist: playlist, showAddPlayist: .constant(false))
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(audioHandler)
                .background(Color.backgroundColor)
                .offset(x: offset.width, y: 0)
                .contentShape(Rectangle())
                .highPriorityGesture(
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
                                        navigationIsActive = true
                                    } else {
                                        self.offset = CGSize(width: -120, height: offset.height)
                                        self.offsetDirection = .left
                                        navigationIsActive = false
                                    }
                                } else if swipeRightShouldStick {
                                    if offsetDirection == .left {
                                        self.offset = CGSize(width: .zero, height: offset.height)
                                        self.offsetDirection = .center
                                        navigationIsActive = true
                                    } else {
                                        self.offset = CGSize(width: 60, height: offset.height)
                                        self.offsetDirection = .right
                                        navigationIsActive = false
                                    }
                                }
                            }
                        }
                )
        }
    }
}

enum OffsetDirection {
    case left
    case center
    case right
}

struct SwipableCardWithButtons_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCard(playlist: Playlist(), showAddPlayist: .constant(true))
    }
}
