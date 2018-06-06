//
//  ViewController.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 5/6/18.
//  Copyright © 2018 Thomas Greenwood. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {
	var currentInfo: MPMediaItem?
	var artworkImage: UIImage?
	@IBOutlet var artworkView: UIImageView!
	@IBOutlet var artistLabel: UILabel!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var singleTapGestureRecognizer: UITapGestureRecognizer!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		artworkImage = UIImage(named: "ye.jpg")
		artworkView.isUserInteractionEnabled = true
		
		if let image = artworkImage {
			artworkView.image = image
			artworkView.contentMode = .scaleAspectFit
		} else {
			print(artworkImage!)
		}
		
	}
	
	@IBAction func imageTapped(_ sender: Any) {
		print("Image tapped!")
	}
	
}

