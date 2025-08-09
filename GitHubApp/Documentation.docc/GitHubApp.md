# ``GitHubApp``

@Metadata {
  @Title("GitHubApp")
  @PageKind(article)
}

Welcome to the GitHubApp documentation. This app showcases a SwiftUI + UIKit architecture with a simple Home module powered by Combine, dependency injection via a lightweight ``ServiceLocator``, and snapshot/UI tests.

## Overview

- Home screen lists upcoming movies and supports search.
- Details screen shows credits and reviews for a selected movie.
- A liked movies tab persists selections locally.
- Networking is abstracted behind ``HomeServiceProtocol`` and implemented by ``HomeService``; tests rely on ``MockHomeService``.
- ``ServiceLocator`` wires dependencies at runtime (see ``GitHubAppSceneDelegate``).

## Architecture

- ``Coordinator``: builds views and manages navigation state.
- ``HomeView`` and ``MovieDetailsView``: SwiftUI views bound to ``HomeViewModel`` and ``MovieDetailsViewModel``.
- ``HomeNavigationRouter``: routes navigation events (SwiftUI via ``Coordinator`` or UIKit fallback).

## Key Types

- ``ServiceLocator``
- ``HomeViewModel``
- ``MovieDetailsViewModel``
- ``HomeServiceProtocol``
- ``HomeService``
- ``HomeAPI``
- ``Coordinator``
- ``HomeView``
- ``MovieDetailsView``

## Getting Started

1. Launch the app; the Home tab loads upcoming movies.
2. Use the search bar to filter results.
3. Tap a movie to view details; like/unlike from lists.

> Note: Set an API key in the Keychain or `API_KEY` environment variable; see ``APIKeysProvider``.

