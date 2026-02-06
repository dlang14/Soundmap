import Foundation

protocol TrackProvider {
    func fetchRandomSong(excluding ids: Set<String>) async throws -> Song
}

final class ITunesTrackProvider: TrackProvider {

    private let session: URLSession = .shared

    // Random-ish search terms to create entropy
    private let searchTerms = [
        // Core emotional / universal
        "love", "heart", "feel", "dream", "hope", "forever",
        "home", "alone", "together", "again",

        // Time / atmosphere
        "night", "midnight", "morning", "summer", "winter",
        "sun", "moon", "stars", "light", "dark",

        // Motion / energy
        "dance", "move", "run", "fly", "drive", "wild",
        "fire", "burn", "electric", "power",

        // Color / vibe
        "blue", "gold", "black", "white", "neon", "red",

        // Indie / poetic
        "echo", "shadow", "glass", "waves", "city", "roads",
        "eyes", "bones", "skin", "breath",

        // Pop / mainstream triggers
        "baby", "tonight", "party", "radio", "music",

        // Rock / alt lean
        "broken", "loud", "silence", "fear", "alive",

        // Hip-hop adjacent (still safe)
        "money", "street", "real", "rise", "dreams"
    ]

    func fetchRandomSong(excluding ids: Set<String>) async throws -> Song {
        for _ in 0..<5 { // try a few times to avoid duplicates
            let song = try await fetchOne()
            if !ids.contains(song.id) {
                return song
            }
        }
        throw NSError(domain: "TrackProvider", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Could not find a unique song"
        ])
    }

    private func fetchOne() async throws -> Song {
        let term = searchTerms.randomElement() ?? "music"

        var components = URLComponents(string: "https://itunes.apple.com/search")!
        components.queryItems = [
            .init(name: "term", value: term),
            .init(name: "media", value: "music"),
            .init(name: "entity", value: "song"),
            .init(name: "limit", value: "50")
        ]

        let (data, _) = try await session.data(from: components.url!)
        let response = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)

        guard let track = response.results.randomElement(),
              let trackId = track.trackId,
              let title = track.trackName,
              let artist = track.artistName
        else {
            throw NSError(domain: "TrackProvider", code: 2)
        }

        let albumArt = track.artworkUrl100?
            .replacingOccurrences(of: "100x100", with: "600x600")

        return Song(
            id: String(trackId),
            title: title,
            artist: artist,
            album: track.collectionName,
            albumArtURL: albumArt,
            spotifyURL: nil // intentionally unused
        )
    }
}

// MARK: - iTunes API Models

private struct ITunesSearchResponse: Decodable {
    let results: [ITunesTrack]
}

private struct ITunesTrack: Decodable {
    let trackId: Int?
    let trackName: String?
    let artistName: String?
    let collectionName: String?
    let artworkUrl100: String?
}
