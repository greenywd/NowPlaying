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
	
    // MARK: - Class Properties
    
    // Struct created with static vars to store the contents of the current song - may be expanded in the future.
	struct Song {
		static var title: String = "Unknown Title"
		static var albumTitle: String = "Unknown Album"
		static var artist: String = "Unknown Artist"
		static var artwork: UIImage?
	}
	
    // Instances used in created the background blur.
	var backgroundArtworkImage: UIImage?
	var blurEffectView: UIVisualEffectView?
	
    // Outlets from IB for the Artwork View and Labels.
	@IBOutlet var artworkView: UIImageView!
	@IBOutlet var artistLabel: UILabel!
	@IBOutlet var titleLabel: UILabel!
	
    // MARK: - Class Functions
    
	override func viewDidLoad() {
		super.viewDidLoad()
	
		MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
		
		// FIXME: App needs to be restarted after giving access to Media Library - maybe move the bulk of this into viewWillAppear?
		// If we aren't authorized to use the Media Library, prompt for access.
		if (MPMediaLibrary.authorizationStatus() != .authorized) {
			artworkView.isHidden = true
			artistLabel.text = "Tap here to authorize NowPlaying to access your music library!"
			artistLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openApplicationSettings)))
			titleLabel.isHidden = true
		} else {
			// If we're authorized, show the artwork view and title label.
			artworkView.isHidden = false
			titleLabel.isHidden = false
		
            // Notification Center Observers to handle when the Now Playing Item changes and when we trigger a 3D Touch action from the Home Screen.
			NotificationCenter.default.addObserver(self, selector: #selector(self.updateLabels), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
			NotificationCenter.default.addObserver(self, selector: #selector(self.share(_:)), name: .shareSong, object: nil)
			
			registerSettingsBundle()
			getNowPlayingInfo()
			updateLabels()
		}
	}
	
    // When the view is set to appear, configure the UI to show either the light or dark theme.
	override func viewWillAppear(_ animated: Bool) {
		if (UserDefaults.standard.bool(forKey: "dark_enabled")) {
            updateBlurEffectView(withStyle: .dark)
			artistLabel.textColor = .lightText
			titleLabel.textColor = .lightText
			self.tabBarController?.tabBar.barStyle = .black
			self.navigationController?.navigationBar.barStyle = .blackTranslucent
		} else {
            updateBlurEffectView(withStyle: .light)
			artistLabel.textColor = .darkText
			titleLabel.textColor = .darkText
			self.tabBarController?.tabBar.barStyle = .default
			self.navigationController?.navigationBar.barStyle = .default
		}
	}
	
    // MARK: - Class Functions (Custom)
    
    // Does this need any extra information? Basically updates the blur view with given style.
	func updateBlurEffectView(withStyle style: UIBlurEffectStyle) {
		blurEffectView = UIVisualEffectView()
		blurEffectView?.tag = 10
		
		if let blurView = self.view.viewWithTag(10) {
			blurView.removeFromSuperview()
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
    // TODO: Update function name.
	// Updates the UI
	@objc func updateLabels() {
        // Before doing anything, let's grab the latest Now Playing data.
        getNowPlayingInfo()
        
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
	
    // Helper function to open the Settings app directly to our pane.
	@objc func openApplicationSettings() {
		if let url = URL(string:UIApplicationOpenSettingsURLString) {
			if UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
	}
    
    // TODO: Add "Share Album" option somewhere - ideally have both Song and Album options present to the user.
    // Let's share something!
	@IBAction func share(_ sender: Any? = nil) {
        // Move the user to the NowPlaying View - necessary for when activating via 3D Touch action.
		tabBarController?.selectedIndex = 0
		
		var toShare = [Any]()
		let text = "Now Playing - " + Song.title + " by " + Song.artist
		
		toShare.append(text)
		
        // If the user wants to share artwork, lets prepare it to be shared.
		if UserDefaults.standard.bool(forKey: "artwork_enabled") {
			if let artwork = Song.artwork {
				toShare.append(artwork)
				// FIXME: Do we need to resize images?
				// toShare.append(image.resizeImage(image: image, newWidth: 600))
			}
		}
		
		// https://stackoverflow.com/a/35931947
		
        // Prepare and present our share sheet.
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
	
    // Helper function to get the data from the Now Playing item and update the Song struct.
	@objc func getNowPlayingInfo() {
		let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
		
		Song.title = systemMusicPlayer?.title ?? "Unknown Title"
		Song.artist = systemMusicPlayer?.artist ?? systemMusicPlayer?.albumArtist ?? "Unknown Artist"
		Song.albumTitle = systemMusicPlayer?.albumTitle ?? "Unknown Album"
		Song.artwork = systemMusicPlayer?.artwork?.image(at: (systemMusicPlayer?.artwork?.bounds.size)!) ?? nil
	}
	
	// TODO: Update status bar colour on appearance change.
	override var preferredStatusBarStyle: UIStatusBarStyle {
		if (UserDefaults.standard.bool(forKey: "dark_enabled")) {
			return .lightContent
		} else {
			return .default
		}
	}
}
