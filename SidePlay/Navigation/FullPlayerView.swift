//
//  FullPlayerView.swift
//  SidePlay
//
//  Created by Jeff Chimney on 2020-09-20.
//

import SwiftUI
import MediaPlayer

struct FullPlayerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var audioHandler: AudioHandler

    @State private var seekPosition: Double = 0
    @State private var showFullPlayer: Bool = false
    @State private var elapsedTime: Int = 0
    @State private var runtime: Int = 0
    @State private var timerIsRunning: Bool = false
    
    var playlist: Playlist?
    var track: Track?
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if const.isIPad() {
            nowPlayingView
                .navigationBarTitle("Now Playing")
        } else {
            NavigationView {
                nowPlayingView
                .navigationBarTitle("Now Playing")
            }
        }
    }
    
    var nowPlayingView: some View {
        return VStack {
            
            Spacer()
            
            //AsyncImage(imageLastPathComponent: $audioHandler.currentlyPlayingTrack.wrappedValue!.playlist!.wrappedImageLastPathComponent)
            if const.isIPad() {
                if $audioHandler.currentlyPlayingTrack.wrappedValue!.playlist!.wrappedImageLastPathComponent == ""  {
                    AsyncImage(imageLastPathComponent: $audioHandler.currentlyPlayingTrack.wrappedValue!.playlist!.wrappedImageLastPathComponent)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                } else {
                    Image(uiImage: UIImage(contentsOfFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent($audioHandler.currentlyPlayingTrack.wrappedValue!.playlist!.wrappedImageLastPathComponent).path) ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                }
            } else {
                if $audioHandler.currentlyPlayingTrack.wrappedValue!.playlist!.wrappedImageLastPathComponent == ""  {
                    AsyncImage(imageLastPathComponent: $audioHandler.currentlyPlayingTrack.wrappedValue!.playlist!.wrappedImageLastPathComponent)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.size.width - 40, alignment: .center)
                        .padding()
                } else {
                    Image(uiImage: UIImage(contentsOfFile: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent($audioHandler.currentlyPlayingTrack.wrappedValue!.playlist!.wrappedImageLastPathComponent).path) ?? UIImage())
                        .resizable()
                        .frame(width: UIScreen.main.bounds.size.width - 40, height: UIScreen.main.bounds.size.width - 40, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding()
                }
            }
            
            HStack {
                Spacer()
                Text("\(audioHandler.playlist?.wrappedName ?? "") \(audioHandler.playlist!.trackArray.firstIndex(of: audioHandler.currentlyPlayingTrack!)! + 1)/\(audioHandler.playlist!.trackArray.count)")
                    .font(.footnote)
                Spacer()
            }
            
            Slider(value: $seekPosition, in: 0...1) { (test) in
                audioHandler.audioPlayer.currentTime = TimeInterval(seekPosition * audioHandler.audioPlayer.duration)
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioHandler.audioPlayer.currentTime
            }
            .onAppear {
                withAnimation(.easeInOut) {
                    seekPosition = audioHandler.audioPlayer.currentTime.magnitude / audioHandler.audioPlayer.duration.magnitude
                }
            }
            .accentColor(.buttonGradientEnd)
            .padding([.leading, .trailing], 25)
            .onReceive(timer) { input in
                if audioHandler.currentlyPlayingTrack != nil {
                    seekPosition = audioHandler.audioPlayer.currentTime.magnitude / audioHandler.audioPlayer.duration.magnitude

                    audioHandler.currentlyPlayingTrack?.progress = audioHandler.audioPlayer.currentTime.magnitude
                    audioHandler.currentlyPlayingTrack?.playlist?.lastPlayed = Date()
                    audioHandler.currentlyPlayingTrack?.playlist?.lastPlayedTrack = audioHandler.currentlyPlayingTrack!.uuid
                    
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
                        .font(Font.system(.caption, design: .monospaced))
                        .padding(.leading)
                        .onAppear {
                            elapsedTime = Int(audioHandler.audioPlayer.currentTime.magnitude)
                        }
                } else {
                    Text("\(elapsedTime/60):\(elapsedTime%60)")
                        .font(Font.system(.caption, design: .monospaced))
                        .padding(.leading)
                        .onAppear {
                            elapsedTime = Int(audioHandler.audioPlayer.currentTime.magnitude)
                        }
                }
                Spacer()
                if runtime%60 < 10 {
                    Text("\(runtime/60):0\(runtime%60)")
                        .font(Font.system(.caption, design: .monospaced))
                        .padding(.trailing)
                        .onAppear {
                            runtime = Int(audioHandler.audioPlayer.duration.magnitude)
                        }
                } else {
                    Text("\(runtime/60):\(runtime%60)")
                        .font(Font.system(.caption, design: .monospaced))
                        .padding(.trailing)
                        .onAppear {
                            runtime = Int(audioHandler.audioPlayer.duration.magnitude)
                        }
                }
            }
            
            // Sleep timer button
            HStack {
                Menu {
                    if audioHandler.timerIsActive {
                        Button(action: {
                            audioHandler.stopTimer()
                        }) {
                            Label("Cancel", systemImage: "xmark.circle.fill")
                        }
                    }
                    Button(action: {
                        audioHandler.stopTimer()
                        audioHandler.setTimer(seconds: 3600)
                    }) {
                        Label("1:00", systemImage: "1.circle")
                    }
                    Button(action: {
                        audioHandler.stopTimer()
                        audioHandler.setTimer(seconds: 2700)
                    }) {
                        Label("0:45", systemImage: "45.circle")
                    }
                    Button(action: {
                        audioHandler.stopTimer()
                        audioHandler.setTimer(seconds: 1800)
                    }) {
                        Label("0:30", systemImage: "30.circle")
                    }
                    Button(action: {
                        audioHandler.stopTimer()
                        audioHandler.setTimer(seconds: 900)
                    }) {
                        Label("0:15", systemImage: "15.circle")
                    }
                } label: {
                    Image(systemName: "timer")
                        .imageScale(.medium)
                        .font(.body)
                        .foregroundColor(.buttonGradientEnd)
                    
                    if audioHandler.timerIsActive {
                        if audioHandler.timerSeconds%60 < 10 {
                            Text("\(audioHandler.timerSeconds/60):0\(audioHandler.timerSeconds%60)")
                                .font(Font.system(.caption, design: .monospaced))
                                .foregroundColor(.elementColor)
                        } else {
                            Text("\(audioHandler.timerSeconds/60):\(audioHandler.timerSeconds%60)")
                                .font(Font.system(.caption, design: .monospaced))
                                .foregroundColor(.elementColor)
                        }
                    }
                }
                    
//                        Button {
//                            showTimerPopover = false
//                            audioHandler.setTimer(seconds: audioHandler.timerSeconds)
//                        } label: {
//                            Text("Set")
//                        }
//                        .padding()
            }
            .padding()
            
            // playback controls
            HStack {
                Spacer()
                // skip back
                Button(action: {
                    audioHandler.skipBackward()
                }, label: {
                    Image(systemName: "gobackward.30")
                        .imageScale(.large)
                        .font(.title)
                        .foregroundColor(.buttonGradientEnd)
                })
                .padding()
                Spacer()
                // play / pause
                Button(action: {
                    if audioHandler.isPlaying {
                        audioHandler.pause()
                    } else {
                        audioHandler.play()
                    }
                }, label: {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [.buttonGradientStart, .buttonGradientEnd]), startPoint: .leading, endPoint: .trailing)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        Image(systemName: audioHandler.isPlaying ? "pause" : "play")
                            .imageScale(.large)
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                })
                .padding()
                Spacer()
                // skip forward
                Button(action: {
                    audioHandler.skipForward()
                }, label: {
                    Image(systemName: "goforward.30")
                        .imageScale(.large)
                        .font(.title)
                        .foregroundColor(.buttonGradientEnd)
                })
                .padding()
                Spacer()
            }
            .padding(.bottom)
            
            HStack {
                Spacer()
                Button {
                    // Show Airplay overlay
                    let rect = CGRect(x: 0, y: 0, width: 0, height: 0)
                    let airplayVolume = MPVolumeView(frame: rect)
                    airplayVolume.showsVolumeSlider = false
                    UIApplication.shared.windows.first?.addSubview(airplayVolume)
                    for view: UIView in airplayVolume.subviews {
                      if let button = view as? UIButton {
                        button.sendActions(for: .touchUpInside)
                        break
                      }
                    }
                    airplayVolume.removeFromSuperview()
                } label: {
                    Image(systemName: "airplayaudio")
                        .imageScale(.medium)
                        .font(.body)
                        .foregroundColor(.buttonGradientEnd)
                }
                Spacer()
            }
            Text(AVAudioSession.sharedInstance().currentRoute.outputs.first?.portName ?? "" == "Speaker" ? "" : AVAudioSession.sharedInstance().currentRoute.outputs.first?.portName ?? "")
                .font(.caption)
                .foregroundColor(.buttonGradientEnd)
            Spacer()
        }
    }
}

struct FullPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        FullPlayerView(playlist: Playlist(), track: Track())
    }
}
