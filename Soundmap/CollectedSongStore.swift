import Foundation
import Combine

@MainActor
final class CollectedSongStore: ObservableObject {
    @Published private(set) var songs: [Song] = []

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("collected_songs.json")
    }()

    init() {
        load()
    }

    func contains(_ songID: String) -> Bool {
        songs.contains(where: { $0.id == songID })
    }

    func add(_ song: Song) {
        guard !contains(song.id) else { return }
        songs.insert(song, at: 0)
        save()
    }

    func clearAll() {
        songs = []
        save()
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            songs = try JSONDecoder().decode([Song].self, from: data)
        } catch {
            songs = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(songs)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // ignore for now; you can add error reporting later
        }
    }
}
