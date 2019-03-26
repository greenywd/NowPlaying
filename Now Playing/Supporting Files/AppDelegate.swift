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

	var window: UIWindow?

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

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		NotificationCenter.default.post(name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		NotificationCenter.default.post(name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
		handleShortcut(shortcutItem)
	}
	
	private func handleShortcut(_ item: UIApplicationShortcutItem) {
		guard let actionType = ShortcutIdentifier(rawValue: item.type) else {
			return
		}
        print(actionType)
		switch (actionType) {
		case .ShareSong:
            (window?.rootViewController!.children.first?.children.first as? NowPlayingViewController)?.share()

		case .ShareAlbum:
			print("Share album")
			
		}
	}
}

