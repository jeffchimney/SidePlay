//
//  PageView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-28.
//

import SwiftUI

struct PageView: View {
    
    @EnvironmentObject var audioHandler: AudioHandler
    
    @State private var counter: Int = 1
    
    var imageLastPathComponent: String
    
    var body: some View {
        TabView {
            AsyncImage(imageLastPathComponent: imageLastPathComponent)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding()
            
            TrackListView(playlist: audioHandler.currentlyPlayingTrack!.playlist!)
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(imageLastPathComponent: "")
    }
}
