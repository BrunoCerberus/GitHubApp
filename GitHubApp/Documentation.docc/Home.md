# Home Module

@Metadata {
  @Title("Home Module")
  @PageKind(article)
}

The Home module fetches and displays movie lists with search and liking functionality.

## Flow

1. ``HomeViewModel`` requests data via ``HomeServiceProtocol``.
2. ``HomeView`` renders a list using fetched ``Movie`` models.
3. ``HomeNavigationRouter`` handles taps, routing to details.
4. ``MovieDetailsViewModel`` loads credits and reviews for ``MovieDetailsView``.

## Networking

- ``HomeService`` uses ``HomeAPI`` for endpoints and conforms to ``HomeServiceProtocol``.
- ``APIKeysProvider`` manages the secure API key via the keychain.

## Dependency Injection

- ``ServiceLocator`` registers ``HomeServiceProtocol`` at launch (mocked during tests).

