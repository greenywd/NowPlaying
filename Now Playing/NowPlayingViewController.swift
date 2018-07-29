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
		static var title: String?
		static var albumTitle: String?
		static var artist: String?
		static var artwork: UIImage?
	}
	
	var backgroundArtworkImage: UIImage?
	var blurEffectView: UIVisualEffectView?
	
	@IBOutlet var artworkView: UIImageView!
	@IBOutlet var artistLabel: UILabel!
	@IBOutlet var titleLabel: UILabel!
	
	@IBOutlet var requestAccessTapGestureRecognizer: UITapGestureRecognizer!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view, typically from a nib.
		self.navigationController?.title = "Now Playing"
		
		// TODO: Authorization: Make sure this is implemented and working
		// this should prompt the MPMediaLibrary auth to show
		MPMediaLibrary.requestAuthorization {(status) in }
		MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
		// if medialibrary isn't authorized, change a label text to prompt for access
		if (MPMediaLibrary.authorizationStatus().rawValue != 3) {
			artworkView.isHidden = true
			artistLabel.text = "Tap here to authorize NowPlaying to access your music library!"
			titleLabel.isHidden = true
			
		} else {
			
			// assume everything else is hidden, and once authorized, show.
			if (MPMediaLibrary.authorizationStatus() == MPMediaLibraryAuthorizationStatus.authorized) {
				artworkView.isHidden = false
				titleLabel.isHidden = false
			}
			
			artworkView.isUserInteractionEnabled = true
			artworkView.contentMode = .scaleAspectFit
			
			registerSettingsBundle()
			
			//MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateLabels), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(self.share(_:)), name: .shareSong, object: nil)
			updateLabels()
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
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
		getNowPlayingInfo()

		artistLabel.text = Song.artist
		titleLabel.text = Song.title
		artworkView.image = Song.artwork
		backgroundArtworkImage = Song.artwork
		
		// FIXME: Use something other than pattern image OR increase the image size so that we can't see the patterning
		if let artwork = Song.artwork {
			self.view.backgroundColor = UIColor(patternImage: artwork)
		}
	}
	
	// FIXME: Don't believe this requests auth
	@IBAction func requestAccess(_ sender: Any) {
		MPMediaLibrary.requestAuthorization {(status) in }
	}
	
	@IBAction func share(_ sender: Any? = nil) {
		// TODO: move to nowplaying view if not there already
		getNowPlayingInfo()
		
		var toShare = [Any]()
		let text = "Now Playing - " + Song.title! + " by " + Song.artist!
		
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
	
	func getNowPlayingInfo() {
		let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
		print("getting info")
		Song.title = systemMusicPlayer?.title ?? "Unknown Title"
		Song.artist = systemMusicPlayer?.artist ?? systemMusicPlayer?.albumArtist ?? "Unknown Artist"
		Song.albumTitle = systemMusicPlayer?.albumTitle ?? "Unknown Album"
		Song.artwork = systemMusicPlayer?.artwork?.image(at: (systemMusicPlayer?.artwork?.bounds.size)!) ?? UIImage.init(named: "DefaultArtwork")!
		
		//return Song.init(title: systemMusicPlayer?.title ?? "Unknown Title", albumTitle: systemMusicPlayer?.albumTitle ?? "Unknown Album", artist: systemMusicPlayer?.artist ?? systemMusicPlayer?.albumArtist ?? "Unknown Artist", artwork: artworkImage)
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
