//
//  String+Extensions.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 22/9/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation

extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
