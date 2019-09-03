//
//  NowPlaying.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 13/2/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import MediaPlayer

struct NowPlaying {
    
    init() {
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    // Helper function to get the data from the Now Playing item and update the Song struct.
    func getNowPlayingInfo() -> Song {
        let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem

        return Song(from: nowPlaying!)
    }
    
    func shareContente() -> [Any] {
        
        let np = getNowPlayingInfo()
        
        let networking = Netw
        
        var toShare = [Any]()
        let text = ""
        
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
