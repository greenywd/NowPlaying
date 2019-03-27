//
//  Song.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 27/3/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit

// Struct created with static vars to store the contents of the current song - may be expanded in the future.
struct Song {
    var title: String? = "Unknown Title"
    var albumTitle: String? = "Unknown Artist"
    var artist: String? = "Unknown Album"
    var artwork: UIImage?
}
