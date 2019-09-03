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
        
        setupNotificationObservers(completion: {
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
    
    // MARK: - Class Functions (Custom)
    
    // Notification Center Observers to handle when the Now Playing Item changes and when we trigger a 3D Touch action from the Home Screen.
    func setupNotificationObservers(completion: () -> ()) {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: UserDefaults.didChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: .MPMediaLibraryUnauthorized, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(_:)), name: .NowPlayingInitialSetup, object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(share(_:)), name: .NowPlayingShareSong, object: nil)
        NotificationCenter.default.addObserver(forName: .NowPlayingShareSong, object: nil, queue: .main , using: {(note) in
            print("Received notification from \(note)")
            self.share()
        })
        completion()
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
            artworkView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(share)))
            titleLabel.isHidden = false
        } else if (notification.name.rawValue == "MPMusicPlayerControllerNowPlayingItemDidChangeNotification") {
            let np = Music.getNowPlayingInfo()
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
    
    @objc func share() {
        // Move the user to the NowPlaying View - necessary for when activating via 3D Touch action.
        self.tabBarController?.selectedIndex = 0
        
        var shareContent = [Any]()
        let actionSheet = UIAlertController(title: "How would you like to share?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Apple Music URL", style: .default, handler: { _ in
            let group = DispatchGroup()
            
            group.enter()
            Networking.search(using: Music.getNowPlayingInfo()) { (url) in
                if let url = url {
                    shareContent.append(url)
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
                activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.saveToCameraRoll]
                
                self.present(activityViewController, animated: true, completion: nil)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Text and Artwork", style: .default, handler: { _ in
            let song = Music.getNowPlayingInfo()
            shareContent.append("\(song.title) by \(song.artist)")
            
            if UserDefaults.standard.bool(forKey: "artwork_enabled") {
                if let artwork = song.artwork {
                    shareContent.append(artwork)
                }
            }
            
            let activityViewController = UIActivityViewController(activityItems: shareContent, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.saveToCameraRoll]
            
            self.present(activityViewController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(actionSheet, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
