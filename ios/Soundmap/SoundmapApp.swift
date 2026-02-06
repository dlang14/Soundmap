import SwiftUI

@main
struct SoundmapApp: App {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var collectedStore = CollectedSongStore()
    @StateObject private var dropStore = SongDropStore(
        trackProvider: ITunesTrackProvider() // swap to BackendTrackProvider(...) later
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environmentObject(locationManager)
                .environmentObject(collectedStore)
                .environmentObject(dropStore)
        }
    }
}
