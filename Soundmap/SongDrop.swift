import Foundation
import CoreLocation

struct SongDrop: Identifiable, Codable, Equatable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    var spawnedAt: Date
    var isCollected: Bool

    init(id: UUID = UUID(), coordinate: CLLocationCoordinate2D, spawnedAt: Date = Date(), isCollected: Bool = false) {
        self.id = id
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.spawnedAt = spawnedAt
        self.isCollected = isCollected
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
