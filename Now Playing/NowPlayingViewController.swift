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
	
	struct Song {
		var title: String
		var albumTitle: String
		var artist: String
		var artwork: UIImage
	}
	
	var backgroundArtworkImage: UIImage?
	var blurEffectView: UIVisualEffectView?
	
	@IBOutlet var nowPlayingLabel: UILabel!
	@IBOutlet var artworkView: UIImageView!
	@IBOutlet var artistLabel: UILabel!
	@IBOutlet var titleLabel: UILabel!
	
	@IBOutlet var requestAccessTapGestureRecognizer: UITapGestureRecognizer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// TODO: Authorization: Make sure this is implemented and working
		// this should prompt the MPMediaLibrary auth to show
		MPMediaLibrary.requestAuthorization {(status) in }
		MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
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
			
			artworkView.isUserInteractionEnabled = true
			artworkView.contentMode = .scaleAspectFit
			
			registerSettingsBundle()
			
			//MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateLabels), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
			updateLabels()
			defaultsChanged()
		}
	}
	
	func updateBlurEffectView(style: UIBlurEffectStyle) {
		blurEffectView = UIVisualEffectView()
		blurEffectView?.tag = 10
		
		if let viewWithTag = self.view.viewWithTag(10) {
			viewWithTag.removeFromSuperview()
		} else {
			print("No need to remove blur view.")
		}
		
		let blurEffect = UIBlurEffect(style: style)
		blurEffectView?.effect = blurEffect
		blurEffectView?.frame = view.bounds
		blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		self.view.insertSubview(blurEffectView!, at: 0)
		
	}
	
	@objc func updateLabels() {
		let nowPlaying = getNowPlayingInfo()
	
		artistLabel.text = nowPlaying.artist
		titleLabel.text = nowPlaying.title
		artworkView.image = nowPlaying.artwork
		backgroundArtworkImage = nowPlaying.artwork
		
		// FIXME: Use something other than pattern image
		self.view.backgroundColor = UIColor(patternImage: nowPlaying.artwork)
		
	}
	
	// FIXME: Don't believe this requests auth
	@IBAction func requestAccess(_ sender: Any) {
		MPMediaLibrary.requestAuthorization {(status) in }
	}
	
	@IBAction func imageTapped(_ sender: Any? = nil) {
		let nowPlaying = getNowPlayingInfo()
		
		var toShare = [Any]()
		let text = "Now Playing - " + nowPlaying.title + " by " + nowPlaying.artist
		
		toShare.append(text)
		
		if UserDefaults.standard.bool(forKey: "artwork_enabled") {
				toShare.append(nowPlaying.artwork)
				// FIXME: Do we need to resize images?
				// toShare.append(image.resizeImage(image: image, newWidth: 600))
			}
		
		// https://stackoverflow.com/a/35931947
		
		let activityViewController = UIActivityViewController(activityItems: toShare, applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = self.artworkView
		activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.saveToCameraRoll]
		
		self.present(activityViewController, animated: true, completion: nil)
	}
	
	// https://gist.github.com/abhimuralidharan/3bcd28041f0bd81053c2f92f384ca693#file-settingsobserver-swift
	func registerSettingsBundle(){
		let appDefaults = [String:AnyObject]()
		UserDefaults.standard.register(defaults: appDefaults)
	}
	
	@objc func defaultsChanged() {
		if (UserDefaults.standard.bool(forKey: "dark_enabled")) {
			updateBlurEffectView(style: .dark)
			nowPlayingLabel.textColor = .lightText
			artistLabel.textColor = .lightText
			titleLabel.textColor = .lightText
		} else {
			updateBlurEffectView(style: .light)
			nowPlayingLabel.textColor = .darkText
			artistLabel.textColor = .darkText
			titleLabel.textColor = .darkText
		}
	}
	
	func getNowPlayingInfo() -> Song {
		let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
		var artworkImage: UIImage
		
		if let artwork = systemMusicPlayer?.artwork {
			artworkImage = artwork.image(at: artwork.bounds.size)!
			
		} else {
			artworkImage = UIImage.init(named: "DefaultArtwork")!
		}
		
		return Song.init(title: systemMusicPlayer?.title ?? "Unknown Title", albumTitle: systemMusicPlayer?.albumTitle ?? "Unknown Album", artist: systemMusicPlayer?.artist ?? systemMusicPlayer?.albumArtist ?? "Unknown Artist", artwork: artworkImage)
	}
	
	// TODO: update status bar colour on appearance change - currently only updates on view load
	override var preferredStatusBarStyle: UIStatusBarStyle {
		if (UserDefaults.standard.bool(forKey: "dark_enabled")) {
			return .lightContent
		} else {
			return .default
		}
	}
}
