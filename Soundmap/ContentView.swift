import SwiftUI

struct ContentView: View {
    @EnvironmentObject var collectedStore: CollectedSongStore
    @EnvironmentObject var dropStore: SongDropStore

    var body: some View {
        TabView {
            MapScreen()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            ProfileView()
                .tabItem {
                    Label("Collection", systemImage: "music.note.list")
                }
        }
        .sheet(item: $dropStore.lastPickup, onDismiss: {
            dropStore.lastPickup = nil
        }) { pickup in
            PickupSheet(pickup: pickup)
        }
        .alert(
            "Can't claim yet",
            isPresented: Binding(
                get: { dropStore.lastClaimError != nil },
                set: { if !$0 { dropStore.lastClaimError = nil } }
            )
        ) {
            Button("OK") {
                dropStore.lastClaimError = nil
            }
        } message: {
            Text(dropStore.lastClaimError ?? "")
        }
    }
}

private struct MapScreen: View {
    @State private var recenterToken = UUID()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            UserMapView(recenterToken: $recenterToken)

            Button {
                recenterToken = UUID()
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding(16)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
        .environmentObject(CollectedSongStore())
        .environmentObject(SongDropStore(trackProvider: MockTrackProvider()))
}
