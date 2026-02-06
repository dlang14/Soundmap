import SwiftUI
import MapKit
import CoreLocation

struct UserMapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var dropStore: SongDropStore

    @State private var cameraPosition: MapCameraPosition = .automatic
    @Binding var recenterToken: UUID

    @State private var didInitialZoom = false

    private var userCoordinate: CLLocationCoordinate2D? {
        locationManager.lastLocation?.coordinate
    }

    @MapContentBuilder
    private func userRegionOverlay(for coordinate: CLLocationCoordinate2D) -> some MapContent {
        // 1-mile ring (claimable zone)
        MapCircle(center: coordinate, radius: 1609.34)
            .foregroundStyle(.blue.opacity(0.15))
            .stroke(.blue.opacity(0.5), lineWidth: 2)
    }

    private func zoomToUser() {
        if let loc = locationManager.lastLocation {
            withAnimation(.easeInOut) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: loc.coordinate,
                        latitudinalMeters: 4000,
                        longitudinalMeters: 4000
                    )
                )
            }
            didInitialZoom = true
        } else {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdating()
            default:
                break
            }
        }
    }

    var body: some View {
        Map(position: $cameraPosition, interactionModes: .all) {
            if let coordinate = userCoordinate {
                UserAnnotation()
                userRegionOverlay(for: coordinate)
            }

            // Drops: always show normal icon, always tappable
            ForEach(dropStore.drops) { drop in
                Annotation("", coordinate: drop.coordinate) {
                    Button {
                        dropStore.claim(dropID: drop.id)
                    } label: {
                        DropMarkerView(isCollected: drop.isCollected)
                    }
                    .buttonStyle(.plain)
                    .disabled(drop.isCollected)
                }
            }
        }
        .mapStyle(.standard)
        .ignoresSafeArea()
        .onAppear {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                locationManager.requestAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdating()
            default:
                break
            }
            zoomToUser()
        }
        .onChange(of: locationManager.lastLocation) { newLoc in
            if let loc = newLoc {
                dropStore.handleLocationUpdate(loc)
            }
            if !didInitialZoom {
                zoomToUser()
            }
        }
        .onChange(of: recenterToken) { _ in
            zoomToUser()
        }
    }
}

private struct DropMarkerView: View {
    let isCollected: Bool

    var body: some View {
        Image(systemName: isCollected ? "checkmark.seal.fill" : "music.note")
            .font(.system(size: 18, weight: .bold))
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(isCollected ? .green.opacity(0.7) : .purple.opacity(0.7), lineWidth: 2)
            )
    }
}

#Preview {
    UserMapView(recenterToken: .constant(UUID()))
        .environmentObject(LocationManager())
        .environmentObject(SongDropStore(trackProvider: ITunesTrackProvider()))
}
