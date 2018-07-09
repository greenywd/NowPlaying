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
	var artworkImage: UIImage?
	
	@IBOutlet var nowPlayingLabel: UILabel!
	@IBOutlet var artworkView: UIImageView!
	@IBOutlet var artistLabel: UILabel!
	@IBOutlet var titleLabel: UILabel!
	
	@IBOutlet var requestAccessTapGestureRecognizer: UITapGestureRecognizer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// if medialibrary isn't authorized, change a label text to prompt for access
		if (MPMediaLibrary.authorizationStatus().rawValue != 3) {
			nowPlayingLabel.isHidden = true
			artworkView.isHidden = true
			artistLabel.text = "Tap here to authorize NowPlaying to access your music library!"
			titleLabel.isHidden = true
			
		} else {
			
			// assume everything else is hidden, and once authorized, show.
			if (nowPlayingLabel.isHidden == true) {
				nowPlayingLabel.isHidden = false
				artworkView.isHidden = false
				titleLabel.isHidden = false
			}
			
			MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
			NotificationCenter.default.addObserver(self, selector: #selector(updateNowPlaying), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
			updateNowPlaying()
			
			artworkView.isUserInteractionEnabled = true
			artworkView.contentMode = .scaleAspectFit
		}
	}
	
	@objc func updateNowPlaying() {
		let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
		
		if let artist = systemMusicPlayer?.artist {
			artistLabel.text = artist
		} else {
			artistLabel.text = "Unknown Artist"
		}
		
		if let album = systemMusicPlayer?.albumTitle {
			//nowPlaying["Album"] = album
			print(album)
		} else {
			
		}
		
		if let title = systemMusicPlayer?.title {
			titleLabel.text = title
		} else {
			titleLabel.text = "Unknown Track"
		}
		
		if let artwork = systemMusicPlayer?.artwork {
			artworkImage = artwork.image(at: artwork.bounds.size)
			artworkView.image = artworkImage
		} else {
			// do something when there's no artwork - currently the artwork doesn't update
		}
		
	}
	@IBAction func requestAccess(_ sender: Any) {
		MPMediaLibrary.requestAuthorization {(status) in }
	}
	
	@IBAction func imageTapped(_ sender: Any) {
		var toShare = [Any]()
		var text = "Now Playing - "
		
		if let title = titleLabel.text {
			print("Adding text...")
			text += title + " by "
		}
		
		if let artist = artistLabel.text {
			print("Adding text...")
			text += artist
		}
		
		toShare.append(text)
		
		if UserDefaults.standard.bool(forKey: "artwork_enabled") {
			if let image = artworkImage {
				print("Adding artwork...")
				toShare.append(image)
				// do we need to resize images?
				// toShare.append(image.resizeImage(image: image, newWidth: 600))
			}
		}
		
		// https://stackoverflow.com/a/35931947

		let activityViewController = UIActivityViewController(activityItems: toShare, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = self.artworkView
		activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.saveToCameraRoll]
		
		self.present(activityViewController, animated: true, completion: nil)
	}
	// https://gist.github.com/abhimuralidharan/3bcd28041f0bd81053c2f92f384ca693#file-settingsobserver-swift
	@objc func defaultsChanged() {
		if (UserDefaults.standard.bool(forKey: "dark_enabled")) {
			self.view.backgroundColor = .init(red: 41/255, green: 42/255, blue: 48/255, alpha: 1)
			nowPlayingLabel.textColor = .lightText
			artistLabel.textColor = .lightText
			titleLabel.textColor = .lightText
		} else {
			self.view.backgroundColor = .white
			nowPlayingLabel.textColor = .darkText
			artistLabel.textColor = .darkText
			titleLabel.textColor = .darkText
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
}
