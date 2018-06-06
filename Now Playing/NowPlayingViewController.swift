//
//  ViewController.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 5/6/18.
//  Copyright © 2018 Thomas Greenwood. All rights reserved.
//

import UIKit
import MediaPlayer

class NowPlayingViewController: UIViewController {
	var currentInfo: MPMediaItem?
	var artworkImage: UIImage?
	
	@IBOutlet var artworkView: UIImageView!
	@IBOutlet var artistLabel: UILabel!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var singleTapGestureRecognizer: UITapGestureRecognizer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateNowPlaying), name: .appDidBecomeActive, object: nil)
		
		updateNowPlaying()
		
		artworkView.isUserInteractionEnabled = true
		artworkView.contentMode = .scaleAspectFit
		
	}
	
	@objc
	func updateNowPlaying() {
		let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
		
		if let artist = systemMusicPlayer?.artist {
			artistLabel.text = artist
		}
		
		if let album = systemMusicPlayer?.albumTitle {
			//nowPlaying["Album"] = album
		}
		
		if let title = systemMusicPlayer?.title {
			titleLabel.text = title
		}
		
		if let artwork = systemMusicPlayer?.artwork {
			artworkImage = artwork.image(at: artwork.bounds.size)
			artworkView.image = artworkImage
		}
		
	}
	
	@IBAction func imageTapped(_ sender: Any) {
		print("Image tapped!")
		
		// text to share
		var text = "#NowPlaying - "
		
		if let title = titleLabel.text {
			text += title + " by "
		}
		
		if let artist = artistLabel.text {
			text += artist
		}
		
		// set up activity view controller
		let textToShare = [text]
		let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
		
		// exclude some activity types from the list (optional)
		activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
		
		// present the view controller
		self.present(activityViewController, animated: true, completion: nil)
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
}

