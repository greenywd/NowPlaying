//
//  Song.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 27/3/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

// Struct created with static vars to store the contents of the current song - may be expanded in the future.
struct Song {
    var title: String
    var albumTitle: String
    var artist: String
    var artwork: UIImage?
    
    init() {
        let playing = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
        self.title = playing?.title ?? "Unknown Title"
        self.albumTitle = playing?.title ?? "Unknown Album"
        self.artist = playing?.artist ?? "Unknown Artist"
        self.artwork = playing?.artwork?.image(at: (playing?.artwork?.bounds.size)!)
    }
    
    init(from mediaItem: MPMediaItem?) {
        self.title = mediaItem?.title ?? "Unknown Title"
        self.albumTitle = mediaItem?.albumTitle ?? "Unknown Album"
        self.artist = mediaItem?.artist ?? "Unknown Artist"
        self.artwork = mediaItem?.artwork?.image(at: (mediaItem?.artwork?.bounds.size)!)
    }
}
