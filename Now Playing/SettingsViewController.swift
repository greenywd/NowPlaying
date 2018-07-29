//
//  SettingsViewController.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 9/6/18.
//  Copyright © 2018 Thomas Greenwood. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {

	@IBOutlet var darkSwitch: UISwitch!
	@IBOutlet var artworkSwitch: UISwitch!
	@IBOutlet var confTextField: UITextField!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		
		setPrefStates()
		defaultsChanged()
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
		
		darkSwitch.addTarget(self, action: #selector(updateUserDefaultsAppearanceDark), for: .valueChanged)
		
		artworkSwitch.addTarget(self, action: #selector(updateUserDefaultsFunctionalityShareArtwork), for: .valueChanged)
		
		view.addGestureRecognizer(tap)
		
		self.confTextField.delegate = self
		
        // Do any additional setup after loading the view.
    }
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		UserDefaults.standard.set(self.confTextField.text, forKey: "share_text_conf")
		
		self.view.endEditing(true)
		return false
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
		
		confTextField.text = UserDefaults.standard.string(forKey: "share_text_conf")
	}
	
	@objc func dismissKeyboard(){
		view.endEditing(true)
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
