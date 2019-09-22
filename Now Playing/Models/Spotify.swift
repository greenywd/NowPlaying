//
//  Spotify.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 22/9/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation

class Spotify {
    let clientID: String
    let clientSecret: String
    var token: String?
    
    init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        
        getToken { (token) in
            self.token = token
            print(token)
        }
        
        print("Finished spotify class")
    }
    
    
    /// Gets a new access token for the Spotify API.
    ///
    /// Only use this when you require a new one (i.e. if the current one expires).
    /// - Parameter completion: Access token is passed through.
    func getToken(completion: @escaping (String?) -> ()) {
        let authURL = URL(string: "https://accounts.spotify.com/api/token")!
        
        var request = URLRequest(url: authURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \((clientID + ":" + clientSecret).toBase64())", forHTTPHeaderField: "Authorization")
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                let results = try JSONDecoder().decode(SpotifyAuthentication.self, from: responseData)
                completion(results.accessToken)
                
            } catch {
                print(error, error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func search(using song: Song, for type: SearchType, completion: @escaping (String?) -> ()) {
        var searchURL = "https://api.spotify.com/v1/"
        
        if (type == .song) {
            searchURL += "search?q=\(song.title) \(song.artist)&type=track"
        } else {
            searchURL += "search?q=\(song.albumTitle) \(song.artist)&type=album"
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
        request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            do {
                if (type == .song) {
                    let results = try JSONDecoder().decode(SpotifySearchTracks.self, from: responseData)
                    completion(results.tracks.items.first?.externalUrls.spotify)
                } else if (type == .album) {
                    let results = try JSONDecoder().decode(SpotifySearchAlbums.self, from: responseData)
                    completion(results.albums.items.first?.externalUrls.spotify)
                }
            } catch {
                print(error, error.localizedDescription)
            }
        }
        task.resume()
    }
}
