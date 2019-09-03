//
//  AppDelegate.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 5/6/18.
//  Copyright © 2018 Thomas Greenwood. All rights reserved.
//

import UIKit
import MediaPlayer

enum ShortcutIdentifier: String {
	case ShareSong = "share-song"
	case ShareAlbum = "share-album"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		let userDefaultsDefaults = [
			"dark_enabled" : (true ? 1 : 0),
			"artwork_enabled" : (true ? 1 : 0),
			"share_text_conf" : "Now Playing - %title% by %artist%"
			] as [String : Any]
		
		UserDefaults.standard.register(defaults: userDefaultsDefaults)
		
		UIApplication.shared.shortcutItems?.removeAll(keepingCapacity: false)
		
		let existingShortcutItems = UIApplication.shared.shortcutItems ?? []
		var updatedShortcutItems = existingShortcutItems
		let shareSong: UIApplicationShortcutItem = UIApplicationShortcutItem(type: "share-song", localizedTitle: "Share Song", localizedSubtitle: "", icon: UIApplicationShortcutIcon(type: .share), userInfo: nil)
		updatedShortcutItems.append(shareSong)
		
		UIApplication.shared.shortcutItems = updatedShortcutItems
		
		print(launchOptions ?? "Default value")
		
		if launchOptions?[.shortcutItem] != nil {
			handleShortcut(launchOptions?[.shortcutItem] as! UIApplicationShortcutItem)
			print("yeet")
		}
		
		print("didFinishLaunchingWithOptions")
		return true
	}

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		handleShortcut(shortcutItem)
	}
	
	private func handleShortcut(_ item: UIApplicationShortcutItem) {
		guard let actionType = ShortcutIdentifier(rawValue: item.type) else {
			return
		}
        print(actionType)
//		switch (actionType) {
//		case .ShareSong:
//            (window?.rootViewController!.children.first?.children.first as? NowPlayingViewController)?.share()
//
//		case .ShareAlbum:
//			print("Share album")
//
//		}
	}
}

