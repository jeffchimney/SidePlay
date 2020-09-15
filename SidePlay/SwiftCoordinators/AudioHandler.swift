import Foundation
import SwiftUI
import AVFoundation
import CoreData

class AudioHandler: NSObject, ObservableObject, AVAudioPlayerDelegate {

    @Published var isPlaying: Bool = false
    @Published var currentlyPlayingTrack: Track?

    var audioPlayer = AVAudioPlayer()
    var fileName = ""
    var playlist: Playlist?
    var viewContext: NSManagedObjectContext?

    override init() {
        super.init()
        audioPlayer.delegate = self
    }

    func playNextTrackInPlaylist() {
        if let unwrappedPlaylist = playlist {
            var hasFoundCurrentTrack = false
            for track in unwrappedPlaylist.trackArray.sorted(by: { $0.wrappedName < $1.wrappedName }) {
                // if we are caught up to the track we just played, and it hasnt yet been played
                if hasFoundCurrentTrack {
                    do {
                        currentlyPlayingTrack = track
                        audioPlayer = try AVAudioPlayer(data: track.data!)
                        audioPlayer.delegate = self
                        audioPlayer.play()
                    } catch {
                        // couldn't load file :(
                    }
                    break
                }
                
                if track.wrappedName == currentlyPlayingTrack?.wrappedName {
                    hasFoundCurrentTrack = true
                }
            }
        }
    }
    
    func playFromWhereWeLeftOff() {
        if let unwrappedPlaylist = playlist {
            for track in unwrappedPlaylist.trackArray.sorted(by: { $0.sortOrder < $1.sortOrder }) {
                // if we are caught up to the track we just played, and it hasnt yet been played
                if track.played == false {
                    do {
                        currentlyPlayingTrack = track
                        audioPlayer = try AVAudioPlayer(data: track.data!)
                        audioPlayer.delegate = self
                        audioPlayer.currentTime = track.progress
                        audioPlayer.play()
                    } catch {
                        // couldn't load file :(
                    }
                    break
                }
            }
        }
    }
    
    func playTrack(track: Track) {
        do {
            currentlyPlayingTrack = track
            playlist = track.playlist
            audioPlayer = try AVAudioPlayer(data: track.data!)
            audioPlayer.delegate = self
            audioPlayer.currentTime = track.progress
            audioPlayer.play()
        } catch {
            // couldn't load file :(
        }
    }
    
    func resumePlaylist(track: Track) {
        if let unwrappedPlaylist = playlist {
            for track in unwrappedPlaylist.trackArray {
                // if we are caught up to the track we just played, and it hasnt yet been played
                if track.played == false {
                    do {
                        currentlyPlayingTrack = track
                        audioPlayer = try AVAudioPlayer(data: track.data!)
                        audioPlayer.delegate = self
                        audioPlayer.currentTime = track.progress
                        audioPlayer.play()
                    } catch {
                        // couldn't load file :(
                    }
                    break
                }
            }
        }
    }
    
    func play() {
        audioPlayer.play()
    }
    
    func pause() {
        audioPlayer.pause()
        currentlyPlayingTrack?.progress = audioPlayer.currentTime.magnitude
        
        do {
            try viewContext!.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish Playing")
        currentlyPlayingTrack!.played = true
        playNextTrackInPlaylist()
        
        
        do {
            try viewContext!.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
