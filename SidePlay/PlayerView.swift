//
//  PlayerView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-09.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var audioPlayer: AVAudioPlayer?
    
    @State var isPlaying = true
    
    var track: Track
    var body: some View {
        VStack {
            Text(track.name!)
            HStack {
                Button(action: {
                    if isPlaying {
                        self.audioPlayer!.pause()
                    } else {
                        self.audioPlayer!.play()
                    }
                    isPlaying.toggle()
                }, label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fit)
                })
            }
        }
        .navigationBarTitle("Now Playing")
        .onAppear {
            self.audioPlayer?.stop()
            self.audioPlayer = try! AVAudioPlayer(data: track.wrappedData)
            track.isPlaying = true
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            self.audioPlayer!.play()
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(audioPlayer: .constant(AVAudioPlayer()), track: Track())
    }
}
