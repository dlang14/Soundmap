import SwiftUI
import MapKit
import CoreLocation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var status: CLAuthorizationStatus

    override init() {
        self.status = manager.authorizationStatus
        super.init()
        manager.delegate = self
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }

    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
            coordinate = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = locations.last?.coordinate
    }
}

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        ZStack {
            Map(position: $position,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: .none,
                annotationItems: []) {
                // No annotations
            }
            .overlay {
                if let coord = locationManager.coordinate {
                    MapCircle(center: coord, radius: 1609)
                        .stroke(Color.accentColor.opacity(0.5), lineWidth: 2)
                        .background(
                            MapCircle(center: coord, radius: 1609)
                                .fill(Color.accentColor.opacity(0.1))
                        )
                }
            }
            if locationManager.status == .notDetermined || locationManager.status == .denied {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("Location access is required to center the map on your position.")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(8)
                            Button("Allow Location Access") {
                                locationManager.requestWhenInUseAuthorization()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .frame(maxWidth: 250)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        Spacer()
                    }
                    Spacer().frame(height: 30)
                }
            }
        }
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
        }
        .onChange(of: locationManager.coordinate) { newCoordinate in
            guard let coord = newCoordinate else { return }
            let region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            position = .region(region)
        }
    }
}

#Preview {
    MapView()
        .onAppear {
            // Simulate a fixed coordinate for preview
            let previewCoordinate = CLLocationCoordinate2D(latitude: 37.334900, longitude: -122.009020)
            let previewRegion = MKCoordinateRegion(center: previewCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            // Since position is private, we simulate by re-instantiating MapView with binding or by the initial .region
            // Here we create a wrapper view to set position for preview:
        }
}

struct MapView_PreviewWrapper: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334900, longitude: -122.009020),
                           span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    )

    var body: some View {
        MapViewWrapper(position: $position)
    }
}

struct MapViewWrapper: View {
    @Binding var position: MapCameraPosition
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            Map(position: $position,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: .none)
            .overlay {
                if let coord = CLLocationCoordinate2D(latitude: 37.334900, longitude: -122.009020) {
                    MapCircle(center: coord, radius: 1609)
                        .stroke(Color.accentColor.opacity(0.5), lineWidth: 2)
                        .background(
                            MapCircle(center: coord, radius: 1609)
                                .fill(Color.accentColor.opacity(0.1))
                        )
                }
            }
        }
    }
}

#Preview {
    MapView_PreviewWrapper()
}
