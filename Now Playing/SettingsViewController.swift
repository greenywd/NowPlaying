//
//  SettingsViewController.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 9/6/18.
//  Copyright © 2018 Thomas Greenwood. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

	@IBOutlet var darkSwitch: UISwitch!
	@IBOutlet var artworkSwitch: UISwitch!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setPrefStates()
		defaultsChanged()
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
		
		darkSwitch.addTarget(self, action: #selector(updateUserDefaultsAppearanceDark), for: .valueChanged)
		
		artworkSwitch.addTarget(self, action: #selector(updateUserDefaultsFunctionalityShareArtwork), for: .valueChanged)

        // Do any additional setup after loading the view.
    }
    
	@objc func updateUserDefaultsAppearanceDark(darkSwitch: UISwitch) {
		UserDefaults.standard.set(darkSwitch.isOn, forKey: "dark_enabled")
	}
	
	@objc func updateUserDefaultsFunctionalityShareArtwork(artworkSwitch: UISwitch) {
		UserDefaults.standard.set(artworkSwitch.isOn, forKey: "artwork_enabled")
	}
	
	@objc func defaultsChanged() {
		if (UserDefaults.standard.bool(forKey: "dark_enabled")) {
			self.navigationController?.navigationBar.barStyle = .blackTranslucent
			self.tabBarController?.tabBar.barStyle = .black
		} else {
			self.navigationController?.navigationBar.barStyle = .default
			self.tabBarController?.tabBar.barStyle = .default
		}
	}
	
	func setPrefStates() {
		if (UserDefaults.standard.string(forKey: "dark_enabled") == "1") {
			darkSwitch.setOn(true, animated: true)
		} else {
			darkSwitch.setOn(false, animated: true)
		}
		
		if (UserDefaults.standard.string(forKey: "artwork_enabled") == "1") {
			artworkSwitch.setOn(true, animated: true)
		} else {
			artworkSwitch.setOn(false, animated: true)
		}
	}
	
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
