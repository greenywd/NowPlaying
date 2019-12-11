//
//  Networking.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 3/9/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}

enum SearchType {
    case song, album
}

class Networking {
    static func search(using song: Song, for type: SearchType, completion: @escaping (String?) -> ()) {
        let baseURL = "https://api.music.apple.com/v1/catalog/AU/"
        var searchURL = ""
        
        if (type == .song) {
            searchURL = baseURL + "search?term=\(song.artist)"+" \(song.title)&types=songs"
        } else {
            searchURL = baseURL + "search?term=\(song.artist)"+" \(song.albumTitle)&types=albums"
        }
        if let encoded = searchURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let encodedURL = URL(string: encoded) {
            searchURL = encodedURL.absoluteString
        }
        
        guard let completeURL = URL(string: searchURL) else {
            print("Error: cannot create URL")
            return
        }
        
        var request = URLRequest(url: completeURL)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in

            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            print(responseData.prettyPrintedJSONString)
            
            do {
                let results = try JSONDecoder().decode(AppleMusicData.self, from: responseData)
                if let songs = results.results.songs {
                    completion(songs.data.first?.attributes.url)
                } else if let albums = results.results.albums {
                    completion(albums.data.first?.attributes.url)
                }
                
            } catch {
                print(error, error.localizedDescription)
            }
        }.resume()
    }
}
