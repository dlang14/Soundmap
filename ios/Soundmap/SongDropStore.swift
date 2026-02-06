import Foundation
import CoreLocation
import Combine

@MainActor
final class SongDropStore: ObservableObject {
    struct Pickup: Identifiable {
        let id = UUID()
        let song: Song
        let dropID: UUID
        let pickedUpAt: Date
    }

    @Published private(set) var drops: [SongDrop] = []
    @Published var lastPickup: Pickup?
    @Published var lastClaimError: String?

    private var lastUserLocation: CLLocation?

    private let trackProvider: TrackProvider

    // Config
    private let spawnRadiusMeters: Double = 5 * 1609.34   // 5 miles: drops can appear within this radius
    private let claimRadiusMeters: Double = 1 * 1609.34   // 1 mile: drops within this are claimable
    private let maxDrops: Int = 150                        // ✅ more drops
    private let minDropSeparationMeters: Double = 20     // ✅ tighter spacing so more fit
    private let autoDropRefreshDistance: Double = 1600 * 3

    private var lastSpawnCenter: CLLocation?
    private var isAwarding = false

    init(trackProvider: TrackProvider) {
        self.trackProvider = trackProvider
    }

    func handleLocationUpdate(_ userLocation: CLLocation) {
        lastUserLocation = userLocation

        if shouldRespawnDrops(userLocation) {
            respawnDrops(around: userLocation)
        }
    }

    /// Drop is "claimable" if it's within the 1-mile radius from current user location.
    func isClaimable(_ drop: SongDrop) -> Bool {
        guard let userLoc = lastUserLocation else { return false }
        let dropLoc = CLLocation(latitude: drop.latitude, longitude: drop.longitude)
        return dropLoc.distance(from: userLoc) <= claimRadiusMeters
    }

    func claim(dropID: UUID) {
        lastClaimError = nil
        guard !isAwarding else { return }

        guard let userLoc = lastUserLocation else {
            lastClaimError = "Waiting for your location…"
            return
        }

        guard let idx = drops.firstIndex(where: { $0.id == dropID }) else { return }
        guard !drops[idx].isCollected else { return }

        let dropLoc = CLLocation(latitude: drops[idx].latitude, longitude: drops[idx].longitude)
        let distance = dropLoc.distance(from: userLoc)

        // ✅ your rule: must be inside 1 mile to claim
        if distance > claimRadiusMeters {
            lastClaimError = "Move closer to claim (within 1 mile)."
            return
        }

        // Mark collected immediately to prevent double-claims
        drops[idx].isCollected = true

        Task {
            await awardSong(for: dropID)
        }
    }

    private func shouldRespawnDrops(_ userLocation: CLLocation) -> Bool {
        guard let center = lastSpawnCenter else { return true }
        // respawn when user moves ~0.5 miles from spawn center
        return center.distance(from: userLocation) > autoDropRefreshDistance
    }

    private func respawnDrops(around userLocation: CLLocation) {
        lastSpawnCenter = userLocation

        var newDrops: [SongDrop] = []
        var attempts = 0

        while newDrops.count < maxDrops && attempts < maxDrops * 60 {
            attempts += 1

            let coord = GeoUtils.randomCoordinate(
                around: userLocation.coordinate,
                radiusMeters: spawnRadiusMeters
            )

            let candidate = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

            // enforce minimum spacing between drops
            let tooClose = newDrops.contains { existing in
                let ex = CLLocation(latitude: existing.latitude, longitude: existing.longitude)
                return ex.distance(from: candidate) < minDropSeparationMeters
            }
            if tooClose { continue }

            newDrops.append(SongDrop(coordinate: coord))
        }

        drops = newDrops
    }

    private func awardSong(for dropID: UUID) async {
        isAwarding = true
        defer { isAwarding = false }

        do {
            let song = try await trackProvider.fetchRandomSong(excluding: [])
            lastPickup = Pickup(song: song, dropID: dropID, pickedUpAt: Date())
        } catch {
            // If awarding fails, un-collect so user can try again
            if let i = drops.firstIndex(where: { $0.id == dropID }) {
                drops[i].isCollected = false
            }
        }
    }
}
