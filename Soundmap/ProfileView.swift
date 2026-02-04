import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var collectedStore: CollectedSongStore

    var body: some View {
        NavigationStack {
            List {
                if collectedStore.songs.isEmpty {
                    ContentUnavailableView(
                        "No songs yet",
                        systemImage: "music.note",
                        description: Text("Walk to a nearby drop to collect your first song.")
                    )
                } else {
                    ForEach(collectedStore.songs) { song in
                        HStack(spacing: 12) {

                            // Album art thumbnail
                            if let urlString = song.albumArtURL,
                               let url = URL(string: urlString) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 56, height: 56)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 56, height: 56)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    case .failure:
                                        fallbackThumb
                                    @unknown default:
                                        fallbackThumb
                                    }
                                }
                            } else {
                                fallbackThumb
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.title)
                                    .font(.headline)
                                    .lineLimit(1)

                                Text(song.artist)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)

                                if let album = song.album, !album.isEmpty {
                                    Text(album)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    Button(role: .destructive) {
                        collectedStore.clearAll()
                    } label: {
                        Text("Clear collection")
                    }
                }
            }
            .navigationTitle("Your Collection")
        }
    }

    private var fallbackThumb: some View {
        Image(systemName: "music.note")
            .font(.system(size: 20))
            .foregroundStyle(.secondary)
            .frame(width: 56, height: 56)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
