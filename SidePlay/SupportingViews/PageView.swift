//
//  PageView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-28.
//

import SwiftUI

struct PageView: View {
    
    @State var counter: Int = 1
    
    @Binding var audioHandler: AudioHandler
    @Binding var isPlaying: Bool
    
    var imageLastPathComponent: String
    
    var body: some View {
        TabView {
            AsyncImage(imageLastPathComponent: imageLastPathComponent)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding()
            
            TrackListView(playlist: audioHandler.currentlyPlayingTrack!.playlist!, audioHandler: $audioHandler, isPlaying: $isPlaying)
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(audioHandler: .constant(AudioHandler()), isPlaying: .constant(false), imageLastPathComponent: "")
    }
}
