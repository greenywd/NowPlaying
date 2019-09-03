//
//  NowPlaying.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 13/2/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import MediaPlayer

struct Music {
    
    // Helper function to get the data from the Now Playing item and update the Song struct.
    static func getNowPlayingInfo() -> Song {
        let nowPlaying = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
        
        return Song(from: nowPlaying!)
    }
}
