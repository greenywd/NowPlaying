//
//  SettingsViewController.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 9/6/18.
//  Copyright © 2018 Thomas Greenwood. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    private let userDefaults = UserDefaults.standard
    
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

        setPrefStates()
    }
    
    // MARK: - Class Functions (Custom)
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userDefaults.set(self.confTextField.text, forKey: "share_text_conf")
        
        self.view.endEditing(true)
        return false
    }

    // Set the UI elements to reflect the user's current preferences.
    func setPrefStates() {
        artworkSwitch.isOn = userDefaults.bool(forKey: "artwork_enabled")

        // TODO: Implement custom share text based on this key
        confTextField.text = UserDefaults.standard.string(forKey: "share_text_conf")
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
