//
//  NowPlaying.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 5/6/18.
//  Copyright © 2018 Thomas Greenwood. All rights reserved.
//

import Foundation
import MediaPlayer

class NowPlaying {
	var trackTitle: String?
	var albumTitle: String?
	var albumArtist: String?
	
	public init(trackTitle: String, albumTitle: String, albumArtist: String) {
		self.trackTitle = trackTitle
		self.albumTitle = albumTitle
		
	}
	
	func getNowPlaying() -> Dictionary<String,String> {
		var nowPlayingDetails = Dictionary<String,String>()
		
		
		
		return nowPlayingDetails
	}
	
}
