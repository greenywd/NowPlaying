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
		static var title: String = "Unknown Title"
		static var albumTitle: String = "Unknown Album"
		static var artist: String = "Unknown Artist"
		static var artwork: UIImage?
	}
	
	var backgroundArtworkImage: UIImage?
	var blurEffectView: UIVisualEffectView?
	
	@IBOutlet var artworkView: UIImageView!
	@IBOutlet var artistLabel: UILabel!
	@IBOutlet var titleLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
		
		// FIXME: app needs to be restarted after giving access
		// if medialibrary isn't authorized, change a label text to prompt for access
		if (MPMediaLibrary.authorizationStatus() != .authorized) {
			artworkView.isHidden = true
			artistLabel.text = "Tap here to authorize NowPlaying to access your music library!"
			artistLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openApplicationSettings)))
			titleLabel.isHidden = true
		} else {
			// assume everything else is hidden, and once authorized, show.
			artworkView.isHidden = false
			titleLabel.isHidden = false
		
			NotificationCenter.default.addObserver(self, selector: #selector(self.getNowPlayingInfo), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateLabels), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(self.share(_:)), name: .shareSong, object: nil)
			
			registerSettingsBundle()
			getNowPlayingInfo()
			updateLabels()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		if (UserDefaults.standard.bool(forKey: "dark_enabled")) {
			updateBlurEffectView(style: .dark)
			artistLabel.textColor = .lightText
			titleLabel.textColor = .lightText
			self.tabBarController?.tabBar.barStyle = .black
			self.navigationController?.navigationBar.barStyle = .blackTranslucent
		} else {
			updateBlurEffectView(style: .light)
			artistLabel.textColor = .darkText
			titleLabel.textColor = .darkText
			self.tabBarController?.tabBar.barStyle = .default
			self.navigationController?.navigationBar.barStyle = .default
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
		
		if let blurView = blurEffectView {
			self.view.insertSubview(blurView, at: 0)
		} else {
			print("Error: Could not insert blurEffectView at layer 0.")
		}
	}
	
	@objc func updateLabels() {
		let playbackState = MPMusicPlayerController.systemMusicPlayer.playbackState
		
		artistLabel.text = (playbackState == .stopped) ? "Start playing some music!" : Song.artist
		titleLabel.text = (playbackState == .stopped) ? "" : Song.title
		
		if (playbackState == .stopped) {
			artworkView.image = nil
		} else {
			if let artwork = Song.artwork {
				artworkView.image = artwork
				backgroundArtworkImage = artwork
				// TODO: center this?
				self.view.backgroundColor = UIColor(patternImage: artwork.resizeImage(image: artwork, newHeight: UIScreen.main.bounds.height)!)
			} else {
				artworkView.image = nil
			}
		}
	}
	
	@objc func openApplicationSettings() {
		if let url = URL(string:UIApplicationOpenSettingsURLString) {
			if UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
	}
	
	@IBAction func share(_ sender: Any? = nil) {
		tabBarController?.selectedIndex = 0
		
		var toShare = [Any]()
		let text = "Now Playing - " + Song.title + " by " + Song.artist
		
		toShare.append(text)
		
		if UserDefaults.standard.bool(forKey: "artwork_enabled") {
			if let artwork = Song.artwork {
				toShare.append(artwork)
				// FIXME: Do we need to resize images?
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
	func registerSettingsBundle(){
		let appDefaults = [String:AnyObject]()
		UserDefaults.standard.register(defaults: appDefaults)
	}
	
	@objc func getNowPlayingInfo() {
		let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
		
		Song.title = systemMusicPlayer?.title ?? "Unknown Title"
		Song.artist = systemMusicPlayer?.artist ?? systemMusicPlayer?.albumArtist ?? "Unknown Artist"
		Song.albumTitle = systemMusicPlayer?.albumTitle ?? "Unknown Album"
		Song.artwork = systemMusicPlayer?.artwork?.image(at: (systemMusicPlayer?.artwork?.bounds.size)!) ?? nil
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
