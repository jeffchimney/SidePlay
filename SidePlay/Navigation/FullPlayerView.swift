//
//  FullPlayerView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-20.
//

import SwiftUI

struct FullPlayerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var audioHandler: AudioHandler
    
    @Binding var isPlaying: Bool
    @State var seekPosition: Double = 0
    @State var showFullPlayer: Bool = false
    @State var elapsedTime: Int = 0
    @State var runtime: Int = 0
    
    var playlist: Playlist?
    var track: Track?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Text(track?.wrappedName ?? audioHandler.currentlyPlayingTrack?.wrappedName ?? "Uknown Track")
                .font(Font.system(.headline))
                .foregroundColor(Color.elementColor)
                .padding()
            
            Spacer()
            
            TrackListView(playlist: audioHandler.currentlyPlayingTrack!.playlist!, seekPosition: $seekPosition, audioHandler: $audioHandler)
                .frame(width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.size.width - 40, alignment: .center)
//                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            Slider(value: $seekPosition, in: 0...1) { (test) in
                audioHandler.audioPlayer.currentTime = TimeInterval(seekPosition * audioHandler.audioPlayer.duration)
            }
            .padding([.leading, .trailing], 25)
            .onReceive(timer) { input in
                if audioHandler.currentlyPlayingTrack != nil {
                    seekPosition = audioHandler.audioPlayer.currentTime.magnitude / audioHandler.audioPlayer.duration.magnitude

                    audioHandler.currentlyPlayingTrack?.progress = audioHandler.audioPlayer.currentTime.magnitude
                    
                    elapsedTime = Int(audioHandler.audioPlayer.currentTime.magnitude)
                    runtime = Int(audioHandler.audioPlayer.duration.magnitude)
                    do {
                        try viewContext.save()
                    } catch {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }
            }
            HStack {
                if elapsedTime%60 < 10 {
                    Text("\(elapsedTime/60):0\(elapsedTime%60)")
                        .font(Font.system(.caption))
                        .foregroundColor(Color.elementColor)
                        .padding(.leading)
                } else {
                    Text("\(elapsedTime/60):\(elapsedTime%60)")
                        .font(Font.system(.caption))
                        .foregroundColor(Color.elementColor)
                        .padding(.leading)
                }
                Spacer()
                if runtime%60 < 10 {
                    Text("\(runtime/60):0\(runtime%60)")
                        .font(Font.system(.caption))
                        .foregroundColor(Color.elementColor)
                        .padding(.trailing)
                } else {
                    Text("\(runtime/60):\(runtime%60)")
                        .font(Font.system(.caption))
                        .foregroundColor(Color.elementColor)
                        .padding(.trailing)
                }
            }
            .padding(.bottom)
            
            // playback controls
            HStack {
                Spacer()
                // skip back
                Button(action: {
                    if audioHandler.audioPlayer.isPlaying {
                        audioHandler.pause()
                        isPlaying = false
                    } else {
                        audioHandler.play()
                        isPlaying = true
                    }
                }, label: {
                    Image(systemName: "gobackward.30")
                        .font(Font.system(.largeTitle))
                })
                .padding()
                Spacer()
                // play / pause
                Button(action: {
                    if audioHandler.audioPlayer.isPlaying {
                        audioHandler.pause()
                        isPlaying = false
                    } else {
                        audioHandler.play()
                        isPlaying = true
                    }
                }, label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fit)
                })
                .padding()
                Spacer()
                // skip forward
                Button(action: {
                    if audioHandler.audioPlayer.isPlaying {
                        audioHandler.pause()
                    } else {
                        audioHandler.play()
                    }
                }, label: {
                    Image(systemName: "goforward.30")
                        .font(Font.system(.largeTitle))
                })
                .padding()
                Spacer()
            }
            Spacer()
        }
        .navigationBarTitle("Now Playing")
    }
}

struct FullPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        FullPlayerView(audioHandler: .constant(AudioHandler()), isPlaying: .constant(false))
    }
}
