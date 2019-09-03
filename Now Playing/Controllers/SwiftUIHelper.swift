//
//  SwiftUIHelper.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 3/9/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class SwiftUIHelper : UIViewController {
    @IBSegueAction func showNowPlayingView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: PlayingView())
    }
}
