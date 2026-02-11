# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a CocoaPods-based iOS project. Always open the `.xcworkspace`, not `.xcodeproj`.

```bash
# Install dependencies
pod install

# Build (Debug)
xcodebuild -workspace Somlimee.xcworkspace -scheme Somlimee -configuration Debug build

# Build (Release)
xcodebuild -workspace Somlimee.xcworkspace -scheme Somlimee -configuration Release build
```

No linter or formatter is configured. Test target (`SomlimeeTests/`) exists but has no tests.

## Dependencies

- **Firebase** (Core, Auth, Firestore) — remote data and authentication
- **Swinject** — dependency injection container
- **SQLite.swift** (~> 0.14.0) — local persistence

## Architecture

Clean Architecture with five layers, each depending only on layers below it:

```
SwiftUI Views → ViewModels → UseCases → Repositories → Data Sources
```

**Data flow**: `FirebaseDataSource` (remote) + `SQLiteDataSource` (local) are composed into `FirebaseSQLiteDataSource`, which implements the unified `DataSource` protocol. Repositories consume `DataSource`; UseCases consume Repositories; ViewModels consume UseCases or Repositories directly.

**DI wiring**: `DIContainer.setupContainer()` registers all services in a Swinject container. The container is propagated to SwiftUI views via a custom `EnvironmentKey` (`@Environment(\.diContainer)`). Data sources are registered with `.container` scope (shared instances); everything else is transient.

**Navigation**: Single `NavigationStack` in `RootView.swift` with a `Route` enum (13 cases). Side menu and profile panel are `ZStack` overlays, not navigation destinations.

**ViewModels**: All use `@Observable` (iOS 17+), never `ObservableObject`.

## Import Rules

| Layer | Allowed imports |
|---|---|
| Entities, Models, Repositories, UseCases, ViewModels | `Foundation` only |
| `SomLimeColors.swift`, `SomLimeFonts.swift` | `UIKit` + `SwiftUI` |
| `Data/` layer | `Firebase`, `SQLite`, `UIKit` |
| SwiftUI Views | `SwiftUI` |

Entities and ViewModels must **never** import UIKit or Firebase.

## Data Layer Boundary

Firebase `Timestamp` values are converted to `String` at the `FirebaseDataSource` boundary via `convertTimestamps()`. Code above the data layer never handles Firebase types.

`SQLiteDatabaseCommands` uses static methods that accept a `database: Connection?` parameter — the connection is initialized in `SomlimeeApp` and passed down, not stored globally.

## Patterns to Follow

- **Constructor injection** for all dependencies — no singletons, no service locator
- **Result type** for use case returns: `Result<Entity, Error>`
- **async/await** for all data operations
- **Protocol + Impl** naming: e.g., `UserRepository` (protocol) + `UserRepositoryImpl` (class)
- Use case classes are prefixed `UC`: `UCGetPost`, `UCWritePost`, etc.

## Key Files

- `SomlimeeApp.swift` — `@main` entry point, Firebase init, DI setup, SQLite init
- `CoreBL/Utils/Configurations/DIContainer.swift` — all Swinject registrations
- `CoreBL/Utils/Configurations/DIEnvironment.swift` — SwiftUI environment key
- `SwiftUIViews/RootView.swift` — NavigationStack + drawer overlays
- `SwiftUIViews/Navigation/Route.swift` — type-safe route enum
- `Data/FirebaseSQLiteDataSource.swift` — composed data source
- `CoreBL/Functions/LocalDataSourceInit.swift` — SQLite table creation and seeding
