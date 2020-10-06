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
            if imageLastPathComponent == ""  {
                AsyncImage(imageLastPathComponent: imageLastPathComponent)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
            } else {
                Image(uiImage: UIImage(contentsOfFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(imageLastPathComponent).path) ?? UIImage())
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding()
            }
            
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
