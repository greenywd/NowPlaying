//
//  Networking.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 3/9/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation

class Networking {
    static func search(using song: Song, completion: @escaping (String?) -> ()) {
        let baseURL = "https://api.music.apple.com/v1/catalog/AU/"
        var searchURL = baseURL + "search?term=\(song.artist)"+" \(song.title)&types=songs"
        if let encoded = searchURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let encodedURL = URL(string: encoded) {
            searchURL = encodedURL.absoluteString
        }
        
        guard let completeURL = URL(string: searchURL) else {
            print("Error: cannot create URL")
            return
        }
        
        print(completeURL)
        
        var request = URLRequest(url: completeURL)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        
        let showTask = URLSession.shared.dataTask(with: request) { (data, response, error) in

            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            // print("ResponseData: \(String(data: responseData, encoding: .utf8))")
            
            do {
                let results = try JSONDecoder().decode(AppleMusicData.self, from: responseData)

                completion(results.results.songs.data.first?.attributes.url)
            } catch {
                print(error, error.localizedDescription)
            }
        }
        showTask.resume()
    }
}
