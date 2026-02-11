# Somlimee Architecture Analysis

## Identified Architecture Pattern
**Clean Architecture with MVVM** (transitioning from legacy singleton services pattern)

## Current Status
The project is undergoing MAJOR architectural restructuring. Git status shows extensive file moves and reorganization, indicating a migration from service-based architecture to Clean Architecture.

## Architectural Layers (Intended)

### 1. Entities Layer (`/Entities`)
- Pure domain models (no dependencies on UIKit/Firebase)
- Examples: UserProfile, LimeRoomPostMeta, LimeRoomPostList, AppStates
- Purpose: Business objects that encapsulate enterprise-wide business rules
- CRITICAL: Should have ZERO external dependencies

### 2. Use Cases Layer (`/UseCases`)
- Application business logic
- Named with UC prefix (UCGetPost, UCGetLimeRoomMeta, UCWritePost)
- Orchestrates data flow between Repositories and Presentation
- Converts between Model DTOs and Entity domain objects
- Dependencies: DOWN to Repositories and Entities only

### 3. Repositories Layer (`/Repositories`)
- Abstractions over data sources (protocol + Impl pattern)
- Examples: PostRepository, UserRepository, BoardRepository
- Converts raw data dictionaries to typed Model objects
- Dependencies: DOWN to Data layer via DataSource protocol

### 4. Data Layer (`/Data`)
- Data source protocols and implementations
- DataSource (protocol) -> FirebaseSQLiteDataSource (coordinator)
- RemoteDataSource (protocol) -> FirebaseDataSource (singleton)
- LocalDataSource (protocol) -> SQLiteDataSource (singleton)
- Purpose: Handle actual data persistence/retrieval

### 5. Models Layer (`/Models`)
- Data Transfer Objects (DTOs)
- Suffixed with "Data" (BoardPostMetaData, ProfileData)
- Purpose: Bridge between raw data and domain entities
- Used by Repositories to structure Firebase/SQLite responses

### 6. Presentation Layer
- **ViewModels** (`/ViewModels`): Protocol + Impl pattern, no UI dependencies
- **ViewControllers** (`/ViewControllers`): UIViewController subclasses, coordinate views
- **Views** (`/Views`): UIKit view components, organized by feature (HomeVC/, LimeRoomVC/, ProfileVC/)
- Dependencies: DOWN to ViewModels and UseCases

### 7. Core Business Logic (`/CoreBL`)
- Cross-cutting concerns and shared utilities
- Structure:
  - `/Failures`: Error types for each layer
  - `/Functions`: Pure business functions
  - `/FirebaseAuthFunctions`: Auth-specific functions
  - `/Utils/Configurations`: DIContainer, colors, fonts, test data
  - `/Utils/Extensions`: UIKit extensions

## Dependency Injection
- **Tool**: Swinject DI container
- **Configuration**: `/CoreBL/Utils/Configurations/DIContainer.swift`
- **Pattern**: Protocol-based registration, resolved via `AppDelegate.container.resolve()`
- **Lifecycle**: Container initialized in AppDelegate.didFinishLaunchingWithOptions

## Key Architectural Rules

### Dependency Direction
```
Views -> ViewControllers -> ViewModels -> UseCases -> Repositories -> Data
                                  ↓           ↓            ↓
                              Entities    Entities     Models
```

### Naming Conventions
- **Entities**: Plain names (UserProfile, LimeRoomMeta)
- **Models**: Suffixed with "Data" (ProfileData, BoardPostMetaData)
- **UseCases**: Prefixed with "UC" (UCGetPost, UCWritePost)
- **Repositories**: Suffixed with "Repository", implementations with "Impl"
- **ViewModels**: Suffixed with "ViewModel", implementations with "Impl"
- **Data Sources**: Suffixed with "DataSource"
- **Failures**: Domain-specific error enums in `/CoreBL/Failures`

### Protocol Pattern
Nearly all services use Protocol + Implementation pattern:
- `HomeViewModel` (protocol) -> `HomeViewModelImpl` (class)
- `PostRepository` (protocol) -> `PostRepositoryImpl` (class)
- `DataSource` (protocol) -> `FirebaseSQLiteDataSource` (class)

## Critical Violations Found

### 1. Entities Layer Pollution
**CRITICAL**: Many entities import UIKit/Firebase
- `/Entities/UserProfile.swift`: imports UIKit (line 8) - REMOVE
- `/Entities/LimeRoomPostContent.swift`: imports UIKit (line 9) - REMOVE
- `/Entities/LimeRoomMeta.swift`: imports UIKit (line 8) - REMOVE
- `/Entities/LimeTestReport.swift`: imports UIKit (line 8) - REMOVE

### 2. View Layer Accessing Firebase Directly
**CRITICAL**: Views/ViewControllers import FirebaseAuth
- `/ViewControllers/HomeViewController.swift`: imports FirebaseAuth (line 9)
- `/ViewControllers/ProfileViewController.swift`: imports FirebaseAuth (line 9)
- `/Views/HomeVC/HomeNavBar.swift`: imports FirebaseAuth (line 9), directly uses Auth.auth() (line 48)
- `/Views/LimeRoomVC/LimeRoomNavBar.swift`: imports FirebaseAuth (line 9)
- `/ViewModels/HomeViewModel.swift`: imports FirebaseAuth (line 9), uses Auth.auth() (line 30, 74)

### 3. ViewModel Accessing Firebase Directly
**MAJOR**: ViewModels should only depend on UseCases, not Firebase
- HomeViewModelImpl directly calls `FirebaseAuth.Auth.auth()` - should delegate to UserRepository

### 4. Duplicate Concepts: Entities vs Models
**MAJOR**: Unclear distinction causing confusion
- UserProfile (Entity) vs ProfileData (Model) - similar but different fields
- Need to clarify: Models = DTOs from data layer, Entities = domain objects

### 5. UseCases Resolving Dependencies Directly
**MINOR**: UseCases use `AppDelegate.container.resolve()` in init
- Should receive dependencies via constructor injection for testability
- Example: `/UseCases/UCGetPost.swift` line 21

### 6. NotDone Folder
**ORGANIZATIONAL**: 13 ViewControllers in `/ViewControllers/NotDone/`
- Indicates incomplete features: LogInViewController, SignUpViewController, etc.
- These are excluded from active architecture but still reference old patterns

### 7. Mixed Async Patterns
**MINOR**: Some code uses Task.init with await, some uses async/await directly
- Standardize on async/await throughout

### 8. Repository Data Transformation
**MINOR**: Repositories do manual dictionary parsing with guard-let chains
- Could benefit from Codable or mapper pattern
- Example: `/Repositories/UserRepository.swift` lines 28-61

## Legacy Patterns Being Migrated Away

### Old Pattern (Singleton Services)
- Files moved/deleted: `Services/` folder eliminated
- `UserLoginService`, `UserSignUpWithEmailService`, `DataSourceService` -> moved to CoreBL/Data

### Old Pattern (View-specific Repositories)
Deleted in recent commits:
- `BoardViewRepository`
- `HomeViewRepository`
- `ProfileViewRepository`
- `SearchViewRepository`
- `PersonalityTestViewRepository`

These were feature-specific and violated single responsibility. Replaced with:
- Domain-specific repositories (PostRepository, BoardRepository, UserRepository)

## Technology Stack
- **UI**: UIKit (programmatic, no storyboards)
- **Backend**: Firebase (Firestore, Auth)
- **Local DB**: SQLite (via SQLite.swift pod)
- **DI**: Swinject
- **Language**: Swift (async/await pattern used)

## File Organization Quality

### Strong Areas
- Clear layer separation in folder structure
- Consistent naming conventions (mostly)
- Protocol-oriented design throughout
- DI container well-organized

### Weak Areas
- Entities contaminated with framework dependencies
- Views/ViewModels bypassing architecture to access Firebase directly
- Temporary data mixed in ViewModels (HomeViewModelImpl has hardcoded test data)
- NotDone folder accumulating incomplete work

## Recommendations Priority

### CRITICAL (Breaks Clean Architecture)
1. Remove all UIKit imports from Entities
2. Remove all Firebase imports from Presentation layer
3. Create UserStatusRepository to abstract auth state
4. Move all Firebase operations behind Repository abstractions

### MAJOR (Architectural Debt)
5. Clarify Entity vs Model distinction and document it
6. Implement constructor injection for UseCases
7. Remove hardcoded test data from ViewModels
8. Implement proper data mapping in Repositories

### MINOR (Code Quality)
9. Standardize async/await patterns
10. Complete or remove NotDone features
11. Add architectural documentation (ARCHITECTURE.md)
12. Add dependency diagrams

## Entry Points
- AppDelegate: DI setup, Firebase config, app state init
- SceneDelegate: Root view controller setup (ContainerHomeViewController)
- ContainerHomeViewController: Main navigation container

## Key Insights
- Architecture is well-designed but enforcement is weak
- Recent refactoring shows strong architectural intent
- Main issue: Presentation layer violating boundaries to access infrastructure directly
- Test data in production code suggests lack of proper testing infrastructure
