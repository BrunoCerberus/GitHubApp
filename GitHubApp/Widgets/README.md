# Upcoming Movies Widget

This widget extension displays upcoming movies from The Movie Database API, using the same data source as your main app.

## Features

- **Real-time Updates**: Shows the latest upcoming movies fetched by your main app
- **Multiple Sizes**: Supports small, medium, and large widget sizes
- **Smart Layout**: Adapts content based on widget size
- **Shared Data**: Uses the same movie data as your main app for consistency

## Setup Instructions

### 1. Create Widget Extension Target

1. In Xcode, go to **File** → **New** → **Target**
2. Choose **Widget Extension** under iOS
3. Name it `GitHubAppWidgetExtension`
4. Make sure "Include Configuration Intent" is unchecked
5. Click **Finish**

### 2. Configure App Groups

1. Select your main app target
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and add **App Groups**
4. Add a group identifier: `group.com.bruno.GitHubApp`
5. Repeat for the widget extension target

### 3. Add Files to Widget Extension

Copy these files to your widget extension target:
- `UpcomingMoviesWidget.swift`
- `SharedMovie.swift`
- `SharedDataManager.swift`
- `UpcomingMoviesWidgetBundle.swift`

### 4. Update Bundle Identifier

Ensure your widget extension has a bundle identifier that follows this pattern:
- Main app: `com.bruno.GitHubApp`
- Widget: `com.bruno.GitHubApp.widget`

### 5. Build and Run

1. Build both targets
2. Run the main app first
3. Add the widget to your home screen
4. The widget will automatically display upcoming movies

## How It Works

### Data Flow

1. **Main App**: Fetches upcoming movies via `HomeService`
2. **WidgetDataManager**: Saves movies to shared storage
3. **Widget**: Reads from shared storage and displays movies
4. **Updates**: Widget refreshes every 2 hours or when data changes

### Shared Storage

The widget uses App Groups to share data with the main app:
- **Key**: `shared_upcoming_movies`
- **Format**: JSON-encoded array of `SharedMovie` objects
- **Update Frequency**: Every time movies are fetched in the main app

### Widget Sizes

- **Small**: Shows 1 movie with poster and title
- **Medium**: Shows 2-3 movies with more details
- **Large**: Shows 3 movies with full overview text

## Customization

### Widget Appearance

You can customize the widget by modifying:
- Colors and fonts in `UpcomingMoviesWidgetEntryView`
- Layout in `MovieRowView`
- Update frequency in `UpcomingMoviesTimelineProvider`

### Data Sharing

To share additional data:
1. Add new properties to `SharedMovie`
2. Update `WidgetDataManager.saveUpcomingMovies()`
3. Modify widget views to display new information

## Troubleshooting

### Widget Not Showing Data

1. Check App Groups are properly configured
2. Verify the main app has fetched movies
3. Check console for any error messages
4. Try removing and re-adding the widget

### Build Errors

1. Ensure all files are added to the widget target
2. Check bundle identifiers match the pattern
3. Verify App Groups capability is added to both targets

### Performance Issues

1. Widget updates are limited by iOS
2. Data is cached for 2 hours
3. Consider reducing image sizes for better performance

## Dependencies

- **WidgetKit**: iOS widget framework
- **SwiftUI**: UI framework
- **Foundation**: Basic data types and encoding

## Notes

- Widgets run in a separate process from the main app
- Network requests are not allowed in widgets
- All data must come from shared storage
- Widget updates are controlled by iOS system
