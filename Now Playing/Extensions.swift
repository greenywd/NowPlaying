//
//  Extensions.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 6/6/18.
//  Copyright © 2018 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
	
	// adaptation of https://stackoverflow.com/a/39809874/8097428
	
	func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage? {
		
		let scale = newHeight / image.size.height
		let newWidth = image.size.width * scale
		UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
		image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage
	}
}

extension Notification.Name {
	static let shareSong = Notification.Name("shareSong")
	static let shareAlbum = Notification.Name("shareAlbum")
}
