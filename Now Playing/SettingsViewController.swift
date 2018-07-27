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
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setPrefStates()
		defaultsChanged()
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
		
		darkSwitch.addTarget(self, action: #selector(updateUserDefaultsAppearanceDark), for: .valueChanged)
        // Do any additional setup after loading the view.
    }
    
	@objc func updateUserDefaultsAppearanceDark(darkSwitch: UISwitch) {
		if (darkSwitch.isOn) {
			UserDefaults.standard.set(true, forKey: "dark_enabled")
		} else {
			UserDefaults.standard.set(false, forKey: "dark_enabled")
		}
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
			darkSwitch.setOn(true, animated: false)
		} else {
			darkSwitch.setOn(false, animated: false)
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
