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
    
    func shareAppleMusic(completion: @escaping (String?) -> ()) {
        let group = DispatchGroup()
        var appleMusicURL: String?
        let np = getNowPlayingInfo()
        group.enter()
        Networking.search(using: np) { (url) in
            if let url = url {
                appleMusicURL = url
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let url = appleMusicURL {
                completion(url)
            }
        }
    }
    
    // https://gist.github.com/abhimuralidharan/3bcd28041f0bd81053c2f92f384ca693#file-settingsobserver-swift
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
}
