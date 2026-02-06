import Foundation

struct Song: Identifiable, Codable, Equatable {
    // Spotify track id (or any stable id from your backend)
    let id: String
    let title: String
    let artist: String
    let album: String?
    let albumArtURL: String?
    let spotifyURL: String?
}
