//
//  SpotifyData.swift
//  Now Playing
//
//  Created by Thomas Greenwood on 22/9/19.
//  Copyright © 2019 Thomas Greenwood. All rights reserved.
//

import Foundation

struct SpotifyAuthentication : Codable {
    let accessToken, tokenType: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

struct SpotifySearchAlbums : Codable {
    let albums: Album
    
    struct Album : Codable {
        let items: [Item]
        
        struct Item : Codable {
            let externalUrls: ExternalUrls
            
            enum CodingKeys: String, CodingKey {
                case externalUrls = "external_urls"
            }
            
            struct ExternalUrls: Codable {
                let spotify: String
            }
        }
    }
}

struct SpotifySearchTracks : Codable {
    let tracks: Tracks

    // MARK: - Tracks
    struct Tracks: Codable {
        let href: String
        let items: [Item]
        let limit: Int
        let next: JSONNull?
        let offset: Int
        let previous: JSONNull?
        let total: Int
    }

    // MARK: - Item
    struct Item: Codable {
        let album: Album
        let artists: [Artist]
        let availableMarkets: [String]
        let discNumber, durationMS: Int
        let explicit: Bool
        let externalIDS: ExternalIDS
        let externalUrls: ExternalUrls
        let href: String
        let id: String
        let isLocal: Bool
        let name: String
        let popularity: Int
        let previewURL: JSONNull?
        let trackNumber: Int
        let type, uri: String

        enum CodingKeys: String, CodingKey {
            case album, artists
            case availableMarkets = "available_markets"
            case discNumber = "disc_number"
            case durationMS = "duration_ms"
            case explicit
            case externalIDS = "external_ids"
            case externalUrls = "external_urls"
            case href, id
            case isLocal = "is_local"
            case name, popularity
            case previewURL = "preview_url"
            case trackNumber = "track_number"
            case type, uri
        }
    }

    // MARK: - Album
    struct Album: Codable {
        let albumType: String
        let artists: [Artist]
        let availableMarkets: [String]
        let externalUrls: ExternalUrls
        let href: String
        let id: String
        let images: [Image]
        let name, releaseDate, releaseDatePrecision: String
        let totalTracks: Int
        let type, uri: String

        enum CodingKeys: String, CodingKey {
            case albumType = "album_type"
            case artists
            case availableMarkets = "available_markets"
            case externalUrls = "external_urls"
            case href, id, images, name
            case releaseDate = "release_date"
            case releaseDatePrecision = "release_date_precision"
            case totalTracks = "total_tracks"
            case type, uri
        }
    }

    // MARK: - Artist
    struct Artist: Codable {
        let externalUrls: ExternalUrls
        let href: String
        let id, name, type, uri: String

        enum CodingKeys: String, CodingKey {
            case externalUrls = "external_urls"
            case href, id, name, type, uri
        }
    }

    // MARK: - ExternalUrls
    struct ExternalUrls: Codable {
        let spotify: String
    }

    // MARK: - Image
    struct Image: Codable {
        let height: Int
        let url: String
        let width: Int
    }

    // MARK: - ExternalIDS
    struct ExternalIDS: Codable {
        let isrc: String
    }

    // MARK: - Encode/decode helpers

    class JSONNull: Codable, Hashable {

        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
        }

        public var hashValue: Int {
            return 0
        }

        public init() {}

        public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
}
