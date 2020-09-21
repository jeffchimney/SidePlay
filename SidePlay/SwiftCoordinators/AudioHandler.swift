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
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        
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
                        audioPlayer = try AVAudioPlayer(contentsOf: track.wrappedURL)
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
                        audioPlayer = try AVAudioPlayer(contentsOf: track.wrappedURL)
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
    
//    func playTrack(track: Track) {
//        do {
//            currentlyPlayingTrack = track
//            playlist = track.playlist
//            audioPlayer = try AVAudioPlayer(data: track.data!)
//            audioPlayer.delegate = self
//            audioPlayer.currentTime = track.progress
//            audioPlayer.play()
//        } catch {
//            // couldn't load file :(
//        }
//    }
//
    func playTrack(track: Track) {
        let audioUrl = track.wrappedURL
        
        currentlyPlayingTrack = track
        playlist = track.playlist

        print("Looking for \(audioUrl)")
        // to check if it exists before downloading it
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let calculatedAudioURL = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        if FileManager.default.fileExists(atPath: calculatedAudioURL.path) {
            print("The file already exists at path")
            do {
                URLSession.shared.downloadTask(with: calculatedAudioURL, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else { return }
                    do {
                        try self.audioPlayer = AVAudioPlayer(contentsOf: location)
                        self.audioPlayer.delegate = self
                        self.audioPlayer.currentTime = track.progress
                        self.audioPlayer.play()
                    } catch { print("Error \(error)") }

                }).resume()
            }
        }
        //else {
//
//            // you can use NSURLSession.sharedSession to download the data asynchronously
//            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
//                guard let location = location, error == nil else { return }
//                do {
//                    // after downloading your file you need to move it to your destination url
//                    try FileManager.default.moveItem(at: location, to: destinationUrl)
//
//                    do {
//                        try self.audioPlayer = AVAudioPlayer(contentsOf: destinationUrl)
//                        self.audioPlayer.delegate = self
//                        self.audioPlayer.play()
//                    } catch { print("Error \(error)") }
//                    print("File moved to documents folder")
//                } catch let error as NSError {
//                    print(error.localizedDescription)
//                }
//            }).resume()
//        }
    }
    
    
    func resumePlaylist(track: Track) {
        if let unwrappedPlaylist = playlist {
            for track in unwrappedPlaylist.trackArray {
                // if we are caught up to the track we just played, and it hasnt yet been played
                if track.played == false {
                    playTrack(track: track)
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
