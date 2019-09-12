//
//  AppleMusicData.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 3/9/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation

struct AppleMusicData : Decodable {
    var results: Results
    
    struct Results : Decodable {
        var songs: Songs?
        var albums: Albums?
        
        struct Songs : Decodable {
            var data: [Data]
            
            struct Data : Decodable {
                var attributes: Attributes
                
                struct Attributes : Decodable {
                    var url: String
                }
            }
        }
        
        struct Albums : Decodable {
            var data: [Data]
            struct Data : Decodable {
                var attributes: Attributes
                
                struct Attributes : Decodable {
                    var url: String
                }
            }
        }
    }
}
