import Foundation

protocol TrackProvider {
    func fetchRandomSong(excluding excludedIDs: Set<String>) async throws -> Song
}

// MARK: - Spotify oEmbed (no auth required)

private struct SpotifyOEmbedResponse: Decodable {
    let thumbnail_url: String?
}

private actor SpotifyOEmbedCache {
    static let shared = SpotifyOEmbedCache()
    private var cache: [String: String] = [:] // key: spotify track url, value: thumbnail_url

    func thumbnailURL(for spotifyTrackURL: String) async throws -> String? {
        if let cached = cache[spotifyTrackURL] { return cached }

        var comps = URLComponents(string: "https://open.spotify.com/oembed")!
        comps.queryItems = [URLQueryItem(name: "url", value: spotifyTrackURL)]
        let url = comps.url!

        let (data, resp) = try await URLSession.shared.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(SpotifyOEmbedResponse.self, from: data)
        if let thumb = decoded.thumbnail_url {
            cache[spotifyTrackURL] = thumb
        }
        return decoded.thumbnail_url
    }
}

// MARK: - Providers

struct MockTrackProvider: TrackProvider {
    // Keep albumArtURL nil (or whatever); we'll hydrate via oEmbed when returning a song.
    private let pool: [Song] = [
        Song(id: "3n3Ppam7vgaVa1iaRUc9Lp", title: "Mr. Brightside", artist: "The Killers", album: "Hot Fuss", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/3n3Ppam7vgaVa1iaRUc9Lp"),
        Song(id: "7GhIk7Il098yCjg4BQjzvb", title: "Never Gonna Give You Up", artist: "Rick Astley", album: "Whenever You Need Somebody", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/7GhIk7Il098yCjg4BQjzvb"),
        Song(id: "2takcwOaAZWiXQijPHIx7B", title: "Time", artist: "Hans Zimmer", album: "Inception", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/2takcwOaAZWiXQijPHIx7B"),
        Song(id: "4cOdK2wGLETKBW3PvgPWqT", title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/4cOdK2wGLETKBW3PvgPWqT"),
        Song(id: "0VjIjW4GlUZAMYd2vXMi3b", title: "Blinding Lights", artist: "The Weeknd", album: "After Hours", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/0VjIjW4GlUZAMYd2vXMi3b"),
        Song(id: "1lDWb6b6ieDQ2xT7ewTC3G", title: "Shape of You", artist: "Ed Sheeran", album: "÷ (Divide)", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/1lDWb6b6ieDQ2xT7ewTC3G"),
        Song(id: "6habFhsOp2NvshLv26DqMb", title: "Closer", artist: "The Chainsmokers", album: "Collage", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/6habFhsOp2NvshLv26DqMb"),
        Song(id: "5ChkMS8OtdzJeqyybCc9R5", title: "Bad Guy", artist: "Billie Eilish", album: "When We All Fall Asleep, Where Do We Go?", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/5ChkMS8OtdzJeqyybCc9R5"),
        Song(id: "3AJwUDP919kvQ9QcozQPxg", title: "Happier", artist: "Marshmello", album: "Joytime II", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/3AJwUDP919kvQ9QcozQPxg"),
        Song(id: "2XU0oxnq2qxCpomAAuJY8K", title: "Sunflower", artist: "Post Malone", album: "Hollywood's Bleeding", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/2XU0oxnq2qxCpomAAuJY8K"),
        Song(id: "0TK2YIli7K1leLovkQiNik", title: "Dance Monkey", artist: "Tones and I", album: "The Kids Are Coming", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/0TK2YIli7K1leLovkQiNik"),
        Song(id: "1rgnBhdG2JDFTbYkYRZAku", title: "Memories", artist: "Maroon 5", album: "Memories", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/1rgnBhdG2JDFTbYkYRZAku"),
        Song(id: "3tjFYV6RSFtuktYl3ZtYcq", title: "Old Town Road", artist: "Lil Nas X", album: "7 EP", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/3tjFYV6RSFtuktYl3ZtYcq"),
        Song(id: "6vBdBCqI5M1rw2MnX2ZvEg", title: "Stressed Out", artist: "Twenty One Pilots", album: "Blurryface", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/6vBdBCqI5M1rw2MnX2ZvEg"),
        Song(id: "1uNFoZAHBGtllmzznpCI3s", title: "Billie Jean", artist: "Michael Jackson", album: "Thriller", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/1uNFoZAHBGtllmzznpCI3s"),
        Song(id: "7ouMYWpwJ422jRcDASZB7P", title: "Smells Like Teen Spirit", artist: "Nirvana", album: "Nevermind", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/7ouMYWpwJ422jRcDASZB7P"),
        Song(id: "2d8JP84HNLKhmd6IYOoupQ", title: "Imagine", artist: "John Lennon", album: "Imagine", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/2d8JP84HNLKhmd6IYOoupQ"),
        Song(id: "3ZFTkvIE7kyPt6Nu3PEa7V", title: "Hey Ya!", artist: "OutKast", album: "Speakerboxxx/The Love Below", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/3ZFTkvIE7kyPt6Nu3PEa7V"),
        Song(id: "7GhIk7Il098yCjg4BQjzvb", title: "Africa", artist: "Toto", album: "Toto IV", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/2374M0fQpWi3dLnB54qaLX"),
        Song(id: "6rqhFgbbKwnb9MLmUQDhG6", title: "Lose Yourself", artist: "Eminem", album: "8 Mile", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/6rqhFgbbKwnb9MLmUQDhG6"),
        Song(id: "4uLU6hMCjMI75M1A2tKUQC", title: "Never Gonna Give You Up", artist: "Rick Astley", album: "Whenever You Need Somebody", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/4uLU6hMCjMI75M1A2tKUQC"),
        Song(id: "0eGsygTp906u18L0Oimnem", title: "Sweet Child O' Mine", artist: "Guns N' Roses", album: "Appetite for Destruction", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/0eGsygTp906u18L0Oimnem"),
        Song(id: "1AhDOtG9vPSOmsWgNW0BEY", title: "Uptown Funk", artist: "Mark Ronson ft. Bruno Mars", album: "Uptown Special", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/1AhDOtG9vPSOmsWgNW0BEY"),
        Song(id: "6Qyc6fS4DsZjB2mRW9DsQs", title: "Hotel California", artist: "Eagles", album: "Hotel California", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/6Qyc6fS4DsZjB2mRW9DsQs"),
        Song(id: "3DarAbFujv6eYNliUTyqtz", title: "Rolling in the Deep", artist: "Adele", album: "21", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/3DarAbFujv6eYNliUTyqtz"),
        Song(id: "5Z01UMMf7V1o0MzF86s6WJ", title: "Seven Nation Army", artist: "The White Stripes", album: "Elephant", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/5Z01UMMf7V1o0MzF86s6WJ"),
        Song(id: "0e7ipj03S05BNilyu5bRzt", title: "Take On Me", artist: "a-ha", album: "Hunting High and Low", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/0e7ipj03S05BNilyu5bRzt"),
        Song(id: "1Je1IMUlBXcx1Fz0WE7oPT", title: "I Want It That Way", artist: "Backstreet Boys", album: "Millennium", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/1Je1IMUlBXcx1Fz0WE7oPT"),
        Song(id: "0tgVpDi06FyKpA1z0VMD4v", title: "Perfect", artist: "Ed Sheeran", album: "÷ (Divide)", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/0tgVpDi06FyKpA1z0VMD4v"),
        Song(id: "2takcwOaAZWiXQijPHIx7B", title: "Time", artist: "Hans Zimmer", album: "Inception", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/2takcwOaAZWiXQijPHIx7B"),
        Song(id: "1cTZMwcBJT0Ka3UJPXOeeN", title: "Viva La Vida", artist: "Coldplay", album: "Viva La Vida or Death and All His Friends", albumArtURL: nil, spotifyURL: "https://open.spotify.com/track/1cTZMwcBJT0Ka3UJPXOeeN")

    ]

    func fetchRandomSong(excluding excludedIDs: Set<String>) async throws -> Song {
        let candidates = pool.filter { !excludedIDs.contains($0.id) }

        // Safe fallback if everything is excluded
        guard let base = (candidates.randomElement() ?? pool.randomElement()) else {
            throw URLError(.cannotFindHost) // pool is empty (shouldn't happen)
        }

        // If we have a Spotify URL, hydrate album art via oEmbed (cached)
        if let spotifyURL = base.spotifyURL, !spotifyURL.isEmpty {
            if let thumb = try await SpotifyOEmbedCache.shared.thumbnailURL(for: spotifyURL) {
                return Song(
                    id: base.id,
                    title: base.title,
                    artist: base.artist,
                    album: base.album,
                    albumArtURL: thumb,
                    spotifyURL: base.spotifyURL
                )
            }
        }

        return base
    }
}

/// Use this once you have a backend endpoint that returns Song JSON.
struct BackendTrackProvider: TrackProvider {
    let baseURL: URL

    func fetchRandomSong(excluding excludedIDs: Set<String>) async throws -> Song {
        var comps = URLComponents(url: baseURL.appendingPathComponent("random-track"), resolvingAgainstBaseURL: false)!
        if !excludedIDs.isEmpty {
            comps.queryItems = [
                URLQueryItem(name: "exclude", value: excludedIDs.joined(separator: ","))
            ]
        }
        let url = comps.url!

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(Song.self, from: data)
    }
}
