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
	
	// https://stackoverflow.com/a/31984155/8097428
	func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
		
		let scale = newWidth / image.size.width
		let newHeight = image.size.height * scale
		UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
		image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return newImage
	}
}
