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
    let nowPlaying = NowPlaying()
    
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
		
        // TODO: Use this when user taps on a button/similar, not automagically upon startup
        if MPMediaLibrary.authorizationStatus() != .authorized {
            nowPlaying.requestAuthorization()
        }
        
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
			
			nowPlaying.registerSettingsBundle()
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
		}
		
		let blurEffect = UIBlurEffect(style: style)
		blurEffectView?.effect = blurEffect
		blurEffectView?.frame = view.bounds
		blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		if let blurView = blurEffectView {
			self.view.insertSubview(blurView, at: 0)
		}
	}
    
    // TODO: Update function name.
	// Updates the UI
	@objc func updateLabels() {
        let np = nowPlaying.getNowPlayingInfo()
		let playbackState = MPMusicPlayerController.systemMusicPlayer.playbackState
		
		artistLabel.text = (playbackState == .stopped) ? "Start playing some music!" : np.artist
		titleLabel.text = (playbackState == .stopped) ? "" : np.title
		
		if (playbackState == .stopped) {
			artworkView.image = nil
		} else {
			if let artwork = np.artwork {
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
    
    // TODO: Add "Share Album" option somewhere - ideally have both Song and Album options present to the user.
    // Let's share something!
	@IBAction func share(_ sender: Any? = nil) {
        sleep(1)
        // Move the user to the NowPlaying View - necessary for when activating via 3D Touch action.
		tabBarController?.selectedIndex = 0
		
		// https://stackoverflow.com/a/35931947
		
        // Prepare and present our share sheet.
		let activityViewController = UIActivityViewController(activityItems: nowPlaying.share(), applicationActivities: nil)
		activityViewController.popoverPresentationController?.sourceView = self.artworkView
		activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.saveToCameraRoll]
		
		self.present(activityViewController, animated: true, completion: nil)
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
