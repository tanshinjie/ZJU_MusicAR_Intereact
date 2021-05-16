//
//  SpotifyAPI.swift
//  mySecondApp
//
//  Created by nextlab02 on 2019/7/17.
//  Copyright © 2019 Tan Shin Jie. All rights reserved.
//

// MARK:- JSON
struct SongInfo {
    let songTitle: String
    let songArtist: String
    let playOffsetMs: Int
}

struct Metadata: Decodable {
    let metadata: MetaDataInfo
}

struct MetaDataInfo: Decodable {
    let music: [MusicInfo]
}

struct MusicInfo: Decodable {
    let artists: [ArtistInfo]
    let title: String
    let play_offset_ms: Int
}

struct ArtistInfo: Decodable {
    let name: String
}

func getSongInfo(_ text: String) -> SongInfo {
    let jsondata = text.data(using: .utf8)!
    do {
        let MusicInfo = try JSONDecoder().decode(Metadata.self, from: jsondata).metadata.music[0]
        let ArtistName = MusicInfo.artists[0].name
        let SongTitle = MusicInfo.title
        let PlayOffsetMs = MusicInfo.play_offset_ms
        print("Song Title: \(SongTitle)")
        print("Artist: \(ArtistName)")
        print("Play Offset/ms: \(PlayOffsetMs)")
        return SongInfo(songTitle: SongTitle, songArtist: ArtistName, playOffsetMs: PlayOffsetMs)
    } catch {
        print("Error: \(error.localizedDescription)")
        return SongInfo(songTitle: "", songArtist: "", playOffsetMs: 0)
    }
}


// MARK:- Spotify API

//"https://api.spotify.com/v1/search?q=\(replaceSpaceWithPercentage20(some song title))&type=track"
//"https://api.spotify.com/v1/audio-features/\(idResult)"
let accessToken = "BQBea1v8pLHQv4Px32Lz3nWBBGSM-Ecxa7NRnxQakGvdUGJgylmRPKBQ-zV5p14J8rqa-ZiEW35EBnbL9Kg"

struct SpotifyMetadata: Decodable {
    let tempo: Float
}

func getTempo(_ data: Data) -> Float {
    print("Running getTempo function")
    if data != Data() {
        do {
            let tempo = try JSONDecoder().decode(SpotifyMetadata.self, from: data).tempo
            print("Song Tempo: \(tempo)")
            return tempo
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    return 0.0
}

struct SpotifyyyMetadata: Decodable {
    let tracks: ItemInfo
}

struct ItemInfo: Decodable {
    let items: [IdInfo]
}

struct IdInfo: Decodable {
    let id: String
}

func getID(_ data: Data) -> String {
    print("Running getID function")
    if data != Data() {
        do {
            let id = try JSONDecoder().decode(SpotifyyyMetadata.self, from: data).tracks.items[0].id
            print("Song ID: \(id)")
            return id
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    return ""
}

func replaceSpaceWithPercentage20(_ songTitle: String) -> String {
    return songTitle.replacingOccurrences(of: " ", with: "%20")
}

func makeGetCall(Endpoint spotifyUrl: String, AccessToken accessToken: String, completionHandler: @escaping (Data?, Error?) -> Void) {
    // Set up the URL request
    let todoEndpoint: String = "\(spotifyUrl)"
    guard let url = URL(string: todoEndpoint) else {
        print("Error: cannot create URL")
        return
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    // set up the session
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    
    // make the request
    let task = session.dataTask(with: urlRequest) {
        (data, response, error) in
        // check for any errors
        guard error == nil else {
            print("error calling GET on /todos/1")
            print(error!)
            completionHandler(nil, error)
            return
        }
        // make sure we got data
        guard let responseData = data else {
            print("Error: did not receive data")
            return
        }
        print("responseData: \(responseData)")
        completionHandler(responseData, nil)
    }
    task.resume()
}

