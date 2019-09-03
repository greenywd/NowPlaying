//
//  PlayingView.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 3/9/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import SwiftUI
import MediaPlayer
import Combine

class CombineSongWrapper {
    let song: Song
    
    init() {
        self.song = Song(from: MPMusicPlayerController.systemMusicPlayer.nowPlayingItem!)
    }
}

struct PlayingView: View {
    @ObservedObject var song = Song()

    var notificationPublisher = NotificationCenter.default.publisher(for: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        .map { value in
            return Song(from: (value.object as! MPMusicPlayerController).nowPlayingItem!)
    }
    
    var body: some View {
        VStack {
            Image(uiImage: song.artwork!)
                .resizable()
                .scaledToFit()
                .padding()
                .onTapGesture {
                    
            }
            VStack {
                Text(song.artist)
                Text("\(song.title)")
            }
        }
        .onReceive(notificationPublisher) { player in
            print("Received publisher")
            self.song.title = player.title
            self.song.albumTitle = player.albumTitle
            self.song.artwork = player.artwork
            self.song.update()
        }
    }
}

struct PlayingView_Previews: PreviewProvider {
    static var previews: some View {
        TabbedView()
    }
}
