import SwiftUI
import WidgetKit

struct UpcomingMoviesWidget: Widget {
    let kind: String = "UpcomingMoviesWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UpcomingMoviesTimelineProvider()) { entry in
            UpcomingMoviesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(Localizable.widget.upcomingMoviesTitle)
        .description(Localizable.widget.upcomingMoviesDescription)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct UpcomingMoviesWidgetEntryView: View {
    let entry: UpcomingMoviesTimelineEntry

    var body: some View {
        VStack(alignment: .leading, spacing: headerSpacing) {
            // Header
            HStack(spacing: 4) {
                Text("🎬")
                    .font(entry.family == .systemSmall ? .caption : .body)
                Text(Localizable.widget.upcomingMoviesTitle)
                    .font(entry.family == .systemSmall ? .caption2 : .caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.bottom, 2)

            // Content
            if let movies = entry.movies, !movies.isEmpty {
                VStack(spacing: contentSpacing) {
                    ForEach(Array(movies.prefix(movieLimit(for: entry.family))), id: \.id) { movie in
                        MovieRowView(movie: movie, family: entry.family)
                    }
                }
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ProgressView()
                            Text(Localizable.widget.loadingMovies)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }

            Spacer(minLength: 0)
        }
        .padding(paddingSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(uiColor: .systemBackground))
    }

    /// Spacing between header and content
    private var headerSpacing: CGFloat {
        entry.family == .systemSmall ? 6 : 8
    }

    /// Spacing between movie rows
    private var contentSpacing: CGFloat {
        entry.family == .systemSmall ? 8 : 10
    }

    /// Widget padding
    private var paddingSize: CGFloat {
        switch entry.family {
        case .systemSmall:
            14
        case .systemMedium:
            16
        default:
            16
        }
    }

    /// Determine the number of movies to show based on widget size
    private func movieLimit(for family: WidgetFamily) -> Int {
        switch family {
        case .systemSmall:
            1
        case .systemMedium:
            2
        case .systemLarge:
            3
        default:
            2
        }
    }
}

struct MovieRowView: View {
    let movie: SharedMovie
    let family: WidgetFamily

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Movie poster - load from cache or show placeholder
            Group {
                if let cachedImage = ImageCacheManager.shared.getCachedImage(movieId: movie.id) {
                    cachedImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: family == .systemSmall ? 45 : 50, height: family == .systemSmall ? 67 : 75)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    // Fallback placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        VStack(spacing: 4) {
                            Image(systemName: "film.stack")
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(.white.opacity(0.8))

                            Text("🎬")
                                .font(.caption2)
                        }
                    }
                    .frame(width: family == .systemSmall ? 45 : 50, height: family == .systemSmall ? 67 : 75)
                }
            }

            // Movie details
            VStack(alignment: .leading, spacing: 3) {
                Text(movie.displayTitle)
                    .font(.system(size: family == .systemSmall ? 11 : 12, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                if family != .systemSmall {
                    Text(movie.displayOverview)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .frame(height: family == .systemSmall ? 67 : 75)
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
