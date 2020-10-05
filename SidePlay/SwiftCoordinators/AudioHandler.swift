import Foundation
import SwiftUI
import AVFoundation
import CoreData
import MediaPlayer

class AudioHandler: NSObject, ObservableObject, AVAudioPlayerDelegate {

    @Published var isPlaying: Bool = false
    @Published var isShowingPlayer: Bool = false
    @Published var currentlyPlayingTrack: Track?

    var audioPlayer = AVAudioPlayer()
    var fileName = ""
    var playlist: Playlist?
    var viewContext: NSManagedObjectContext?

    override init() {
        super.init()
        
        audioPlayer.delegate = self
    }
    
    func setupRemoteTransportControls() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
        
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()

        // Add handler for Play Command
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.audioPlayer.rate == 0.0 {
                play()
                return .success
            }
            return .commandFailed
        }

        // Add handler for Pause Command
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.audioPlayer.rate == 1.0 {
                pause()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [30]
        commandCenter.skipBackwardCommand.addTarget { [unowned self] event in
            skipBackward()
            return .success
        }
        
        // Add handler for Pause Command
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [30]
        commandCenter.skipForwardCommand.addTarget { [unowned self] event in
            skipForward()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(changePlaybackPositionCommand(_:)))
    }
    
    func setupNowPlaying() {
        setupRemoteTransportControls()
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentlyPlayingTrack?.wrappedName
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let calculatedImageURL = documentsDirectoryURL.appendingPathComponent(playlist!.wrappedImageLastPathComponent)
        if let image = UIImage(contentsOfFile: calculatedImageURL.path) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func playNextTrackInPlaylist() {
        if let unwrappedPlaylist = playlist {
            var hasFoundCurrentTrack = false
            for track in unwrappedPlaylist.trackArray.sorted(by: { $0.wrappedName < $1.wrappedName }) {
                // if we are caught up to the track we just played, and it hasnt yet been played
                if hasFoundCurrentTrack {
                    currentlyPlayingTrack = track
                    playTrack(track: currentlyPlayingTrack!)
                    break
                }
                
                if track.wrappedName == currentlyPlayingTrack?.wrappedName {
                    hasFoundCurrentTrack = true
                }
            }
        }
    }
    
    func playFromWhereWeLeftOff() {
        isPlaying = true
        if let unwrappedPlaylist = playlist {
            let sortedPlaylist = unwrappedPlaylist.trackArray.sorted(by: { $0.sortOrder < $1.sortOrder })
            for track in sortedPlaylist {
                // if we are caught up to the track we just played, and it hasnt yet been played
                if track.uuid == unwrappedPlaylist.lastPlayedTrack {
                    let audioUrl = track.wrappedURL
                    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let calculatedAudioURL = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
                    if FileManager.default.fileExists(atPath: calculatedAudioURL.path) {
                        currentlyPlayingTrack = track
                        playlist = track.playlist
                        
                        print("The file found at path")
                        do {
                            URLSession.shared.downloadTask(with: calculatedAudioURL, completionHandler: { (location, response, error) -> Void in
                                guard let location = location, error == nil else { return }
                                do {
                                    try self.audioPlayer = AVAudioPlayer(contentsOf: location)
                                    self.audioPlayer.delegate = self
                                    self.audioPlayer.currentTime = track.progress
                                    self.audioPlayer.play()
                                    self.setupNowPlaying()
                                } catch { print("Error \(error)") }

                            }).resume()
                        }
                    }
                    break
                }
            }
        }
    }
    
    func playTrack(track: Track) {
        isPlaying = true
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
                        self.setupNowPlaying()
                    } catch { print("Error \(error)") }

                }).resume()
            }
        }
    }
    
    
//    func resumePlaylist(track: Track) {
//        if let unwrappedPlaylist = playlist {
//            for track in unwrappedPlaylist.trackArray {
//                // if we are caught up to the track we just played, and it hasnt yet been played
//                if track.played == false {
//                    playTrack(track: track)
//                    break
//                }
//            }
//        }
//    }
    
    func play() {
        audioPlayer.rate = 1.0
        isPlaying = true
        audioPlayer.play()
        setupNowPlaying()
    }
    
    func pause() {
        audioPlayer.rate = 0.0
        isPlaying = false
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
    
    func skipForward() {
        audioPlayer.currentTime += 30
        MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
    }
    
    func skipBackward() {
        audioPlayer.currentTime -= 30
        MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Did finish Playing")
        // set played = true and progress = 0 on the played track, so that if it is played again, it starts from the beginning.
        currentlyPlayingTrack!.played = true
        currentlyPlayingTrack!.progress = 0
        
        do {
            try viewContext!.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        playNextTrackInPlaylist()
    }
    
    @objc func changePlaybackPositionCommand(_ event:
              MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        let time = event.positionTime
        
        audioPlayer.currentTime = time
        
        return MPRemoteCommandHandlerStatus.success
    }
}
