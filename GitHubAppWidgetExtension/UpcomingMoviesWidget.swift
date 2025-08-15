import SwiftUI
import WidgetKit

struct UpcomingMoviesWidget: Widget {
    let kind: String = "UpcomingMoviesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UpcomingMoviesTimelineProvider()) { entry in
            UpcomingMoviesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Upcoming Movies")
        .description("Shows upcoming movies from The Movie Database")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct UpcomingMoviesWidgetEntryView: View {
    let entry: UpcomingMoviesTimelineEntry

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("🎬")
                    .font(.title2)
                Text("Upcoming Movies")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
            }

            if let movies = entry.movies, !movies.isEmpty {
                ForEach(Array(movies.prefix(entry.family == .systemSmall ? 1 : 3)), id: \.id) { movie in
                    MovieRowView(movie: movie, family: entry.family)
                }
            } else {
                Text("Loading movies...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }
}

struct MovieRowView: View {
    let movie: SharedMovie
    let family: WidgetFamily

    var body: some View {
        HStack(spacing: 8) {
            if let posterURL = movie.posterURL {
                AsyncImage(url: posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 40, height: 60)
                .cornerRadius(6)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 60)
                    .cornerRadius(6)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(movie.displayTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(family == .systemSmall ? 1 : 2)

                Text(movie.displayOverview)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(family == .systemSmall ? 1 : 2)
            }

            Spacer()
        }
    }
}

struct UpcomingMoviesTimelineEntry: TimelineEntry {
    let date: Date
    let movies: [SharedMovie]?
    let family: WidgetFamily
}

struct UpcomingMoviesTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> UpcomingMoviesTimelineEntry {
        UpcomingMoviesTimelineEntry(
            date: Date(),
            movies: nil,
            family: context.family
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (UpcomingMoviesTimelineEntry) -> Void) {
        let movies = SharedDataManager.shared.getUpcomingMovies()
        let entry = UpcomingMoviesTimelineEntry(
            date: Date(),
            movies: movies.isEmpty ? nil : movies,
            family: context.family
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<UpcomingMoviesTimelineEntry>) -> Void) {
        let movies = SharedDataManager.shared.getUpcomingMovies()
        let entry = UpcomingMoviesTimelineEntry(
            date: Date(),
            movies: movies.isEmpty ? nil : movies,
            family: context.family
        )

        // Update every 2 hours or when data becomes stale
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}
