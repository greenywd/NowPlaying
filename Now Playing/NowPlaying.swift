//
//  NowPlaying.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 13/2/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import MediaPlayer
import UIKit

class NowPlaying {
    
    // Struct created with static vars to store the contents of the current song - may be expanded in the future.
    struct Song {
        var title: String?
        var albumTitle: String?
        var artist: String?
        var artwork: UIImage?
    }
    
    init() {
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    func requestAuthorization() {
        MPMediaLibrary.requestAuthorization() { status in
            
        }
    }
    
    // Helper function to get the data from the Now Playing item and update the Song struct.
    func getNowPlayingInfo() -> Song {
        let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
        
        var np = Song()
        np.title = systemMusicPlayer?.title ?? "Unknown Title"
        np.artist = systemMusicPlayer?.artist ?? systemMusicPlayer?.albumArtist ?? "Unknown Artist"
        np.albumTitle = systemMusicPlayer?.albumTitle ?? "Unknown Album"
        np.artwork = systemMusicPlayer?.artwork?.image(at: (systemMusicPlayer?.artwork?.bounds.size)!) ?? nil
        
        return np
    }
    
    func share() -> [Any] {
        let np = self.getNowPlayingInfo()
        
        var toShare = [Any]()
        let text = "Now Playing - " + (np.title ?? "Unknown Title") + " by " + (np.artist ?? "Unknown Artist")
        
        toShare.append(text)
        
        // If the user wants to share artwork, lets prepare it to be shared.
        if UserDefaults.standard.bool(forKey: "artwork_enabled") {
            if let artwork = np.artwork {
                toShare.append(artwork)
                // FIXME: Do we need to resize images?
                // toShare.append(image.resizeImage(image: image, newWidth: 600))
            }
        }
        
        return toShare
    }
    
    // https://gist.github.com/abhimuralidharan/3bcd28041f0bd81053c2f92f384ca693#file-settingsobserver-swift
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
}
