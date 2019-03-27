//
//  SettingsViewController.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 9/6/18.
//  Copyright © 2018 Thomas Greenwood. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    
    enum Theme: Int {
        case light = 0
        case dark = 1
    }
    
    private var currentTheme: Theme {
        return getCurrentTheme()
    }
    
    private let userDefaults = UserDefaults.standard
    
    @IBOutlet var darkSwitch: UISwitch!
    @IBAction func darkSwitchChanged(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: "dark_enabled")
        updateAppearance()
    }
    
    @IBOutlet var artworkSwitch: UISwitch!
    @IBAction func artworkSwitchChanged(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: "artwork_enabled")
    }
    
    @IBOutlet var confTextField: UITextField!
    
    // MARK: - Class Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.confTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateAppearance()
        setPrefStates()
    }
    
    // MARK: - Class Functions (Custom)
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userDefaults.set(self.confTextField.text, forKey: "share_text_conf")
        
        self.view.endEditing(true)
        return false
    }
    
    // Set dark mode on/off
    func updateAppearance() {
        if currentTheme == .light {
            self.navigationController?.navigationBar.barStyle = .default
            self.tabBarController?.tabBar.barStyle = .default
        } else {
            self.navigationController?.navigationBar.barStyle = .black
            self.tabBarController?.tabBar.barStyle = .black
        }
    }

    // Set the UI elements to reflect the user's current preferences.
    func setPrefStates() {
        darkSwitch.isOn = userDefaults.bool(forKey: "dark_enabled")
        artworkSwitch.isOn = userDefaults.bool(forKey: "artwork_enabled")

        // TODO: Implement custom share text based on this key
        confTextField.text = UserDefaults.standard.string(forKey: "share_text_conf")
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func getCurrentTheme () -> Theme {
        let theme = userDefaults.bool(forKey: "dark_enabled")
        return theme ? .dark : .light
    }
}
