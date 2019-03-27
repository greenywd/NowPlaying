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
    
    @IBOutlet var blurView: UIVisualEffectView!
    
    // @IBOutlet var blurEffectView: UIVisualEffectView!
    //var blurEffectView: UIVisualEffectView?
    
    // Outlets from IB for the Artwork View and Labels.
    @IBOutlet weak var artworkView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nowPlaying.registerSettingsBundle()
        
        setupNotificationObservers(completion: {() in
            print("setupNotificationObservers(completion: )")
            if (MPMediaLibrary.authorizationStatus() == .authorized) {
                print(MPMediaLibrary.authorizationStatus())
                updateUI(NSNotification(name: UserDefaults.didChangeNotification, object: nil))
                NotificationCenter.default.post(name: .NowPlayingInitialSetup, object: nil)
                
            } else if (MPMediaLibrary.authorizationStatus() != .authorized) {
                NotificationCenter.default.post(name: .MPMediaLibraryUnauthorized, object: nil)
            }
        })
        
        if (MPMediaLibrary.authorizationStatus() == .denied || MPMediaLibrary.authorizationStatus() == .notDetermined) {
            NotificationCenter.default.post(name: .MPMediaLibraryUnauthorized, object: nil)
            
            let authorizationAlert = UIAlertController(title: "NowPlaying", message: "Message", preferredStyle: .alert)
            
            authorizationAlert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { (alert: UIAlertAction!) in
                MPMediaLibrary.requestAuthorization() { status in
                    if (MPMediaLibrary.authorizationStatus() == .authorized) {
                        NotificationCenter.default.post(name: .NowPlayingInitialSetup, object: nil)
                    }
                }
            }))
            
            authorizationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) in
                
            }))
            
            present(authorizationAlert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    // MARK: - Class Functions (Custom)
    
    // Notification Center Observers to handle when the Now Playing Item changes and when we trigger a 3D Touch action from the Home Screen.
    func setupNotificationObservers(completion: () -> Void) {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: UserDefaults.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: .MPMediaLibraryUnauthorized, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: .NowPlayingInitialSetup, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(share(_:)), name: .NowPlayingShareSong, object: nil)
        NotificationCenter.default.addObserver(forName: .NowPlayingShareSong, object: nil, queue: .main , using: {(note) in
            print("Received notification from \(note)")
            self.share(self.nowPlaying.getNowPlayingInfo())
        })
        completion()
    }
    
    // Updates the blur view with given style, useful for when preferences are changed.
    func updateBlurEffectView(withStyle style: UIBlurEffect.Style) {
        DispatchQueue.main.async {
            self.blurView?.tag = 10
            
            if let blur = self.view.viewWithTag(10) {
                blur.removeFromSuperview()
            }
            
            let blurEffect = UIBlurEffect(style: style)
            self.blurView?.effect = blurEffect
            self.blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            if let blur = self.blurView {
                self.view.insertSubview(blur, at: 0)
            }
        }
    }
    
    @objc func updateUI(_ sender: NSNotification?) {
        
        guard let notification = sender else { return }
        
        print(notification.name.rawValue)
        
        if (notification.name.rawValue == "MPMediaLibraryUnauthorized") {
            if (MPMediaLibrary.authorizationStatus() != .authorized) {
                artworkView.isHidden = true
                artistLabel.text = "Tap here to authorize NowPlaying to access your music library!"
                artistLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openApplicationSettings)))
                titleLabel.isHidden = true
            }
        } else if (notification.name.rawValue == "NowPlayingInitialSetup") {
            artworkView.isHidden = false
            artworkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(share(_:))))
            titleLabel.isHidden = false
        } else if (notification.name.rawValue == "NSUserDefaultsDidChangeNotification") {
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
        } else if (notification.name.rawValue == "MPMusicPlayerControllerNowPlayingItemDidChangeNotification") {
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
                    view.backgroundColor = UIColor(patternImage: artwork.resizeImage(image: artwork, newHeight: view.bounds.height)!)
                } else {
                    artworkView.image = nil
                }
            }
        }
    }
    
    @objc func openApplicationSettings() {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
    }
    
    // TODO: Add "Share Album" option somewhere - ideally have both Song and Album options present to the user.
    // Let's share something!
    
    @objc func share(_ sender: Any? = nil) {
        
        // Move the user to the NowPlaying View - necessary for when activating via 3D Touch action.
        tabBarController?.selectedIndex = 0
        
        var activityViewController: UIActivityViewController?
        
        if let currentSong = sender as? Song {
            activityViewController = UIActivityViewController(activityItems: nowPlaying.share(song: currentSong), applicationActivities: nil)
        } else {
            activityViewController = UIActivityViewController(activityItems: nowPlaying.share(), applicationActivities: nil)
        }
        
        // https://stackoverflow.com/a/35931947
        
        // Prepare and present our share sheet.
        activityViewController?.popoverPresentationController?.sourceView = self.artworkView
        activityViewController?.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.saveToCameraRoll]
        
        self.present(activityViewController!, animated: true, completion: nil)
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
