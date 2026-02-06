import SwiftUI

struct PickupSheet: View {
    let pickup: SongDropStore.Pickup
    @EnvironmentObject var collectedStore: CollectedSongStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {

            // Album art
            if let urlString = pickup.song.albumArtURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 160, height: 160)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    case .failure:
                        fallbackArt
                    @unknown default:
                        fallbackArt
                    }
                }
            } else {
                fallbackArt
            }

            Text("You found a song!")
                .font(.title2)
                .bold()

            VStack(spacing: 4) {
                Text(pickup.song.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(pickup.song.artist)
                    .foregroundStyle(.secondary)

                if let album = pickup.song.album, !album.isEmpty {
                    Text(album)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                collectedStore.add(pickup.song)
                dismiss() // ✅ auto-close
            } label: {
                Text("Add to my collection")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Spacer(minLength: 0)
        }
        .padding()
        .presentationDetents([.medium])
    }

    private var fallbackArt: some View {
        Image(systemName: "music.note")
            .font(.system(size: 48))
            .foregroundStyle(.secondary)
            .frame(width: 160, height: 160)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
