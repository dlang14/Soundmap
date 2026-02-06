import Foundation
import CoreLocation

enum GeoUtils {
    /// Uniform random point in a circle (uniform area distribution).
    static func randomCoordinate(around center: CLLocationCoordinate2D, radiusMeters: Double) -> CLLocationCoordinate2D {
        // Random distance with uniform area: r = R * sqrt(u)
        let u = Double.random(in: 0...1)
        let v = Double.random(in: 0...1)
        let r = radiusMeters * sqrt(u)
        let theta = 2 * Double.pi * v

        let dx = r * cos(theta) // meters east
        let dy = r * sin(theta) // meters north

        return offsetCoordinate(center: center, metersEast: dx, metersNorth: dy)
    }

    static func offsetCoordinate(center: CLLocationCoordinate2D, metersEast: Double, metersNorth: Double) -> CLLocationCoordinate2D {
        let earthRadius = 6_378_137.0 // meters
        let dLat = metersNorth / earthRadius
        let dLon = metersEast / (earthRadius * cos(center.latitude * Double.pi / 180))

        let newLat = center.latitude + (dLat * 180 / Double.pi)
        let newLon = center.longitude + (dLon * 180 / Double.pi)

        return CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
    }
}
