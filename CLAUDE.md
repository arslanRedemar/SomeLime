# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a CocoaPods-based iOS project. Always open the `.xcworkspace`, not `.xcodeproj`.

```bash
# Install dependencies
pod install

# Build (Debug, Simulator)
xcodebuild -workspace Somlimee.xcworkspace -scheme Somlimee -configuration Debug \
  -destination 'generic/platform=iOS Simulator' build

# Build (Release)
xcodebuild -workspace Somlimee.xcworkspace -scheme Somlimee -configuration Release build
```

No linter or formatter is configured. Test target (`SomlimeeTests/`) exists but has minimal tests.

## Dependencies

- **Firebase** (Core, Auth, Firestore, Storage) — remote data and authentication
- **Swinject** — dependency injection container
- **SQLite.swift** (~> 0.14.0) — local persistence

## Architecture

Clean Architecture with five layers, each depending only on layers below it:

```
SwiftUI Views (22 screens, 18 components)
       ↓
ViewModels (18, all @Observable)
       ↓
UseCases (12, prefixed UC)
       ↓
Repositories (12 protocols + impls)
       ↓
Data Sources (FirebaseDataSource + SQLiteDataSource → FirebaseSQLiteDataSource)
```

### Data Layer

Three protocol tiers compose the data layer:

| Protocol | Impl | Methods | Scope | Purpose |
|---|---|---|---|---|
| `RemoteDataSource` | `FirebaseDataSource` | 18 | `.container` | Firestore/Auth operations |
| `LocalDataSource` | `SQLiteDataSource` | 5 | `.container` | SQLite cache operations |
| `DataSource` | `FirebaseSQLiteDataSource` | 22 | `.container` | Unified facade composing remote + local |

`FirebaseSQLiteDataSource` delegates each method to either the remote or local source. Repositories consume only `DataSource`.

`AuthRepository` (protocol in `Repositories/`, impl `FirebaseAuthRepository` in `Data/`) handles Firebase Auth directly — it is **not** a `DataSource` consumer. Registered with `.container` scope.

### DI Wiring

`DIContainer.setupContainer()` registers all services in a Swinject `Container`. The container is propagated to SwiftUI views via a custom `EnvironmentKey` (`@Environment(\.diContainer)` defined in `DIEnvironment.swift`).

**Container-scoped** (shared singleton per container): `RemoteDataSource`, `LocalDataSource`, `DataSource`, `AuthRepository`

**Transient** (new instance per resolve): all Repositories, UseCases, ViewModels

### Navigation

Single `NavigationStack` in `RootView.swift` with a `Route` enum (20 cases). Side menu (280pt, left) and profile panel (300pt, right) are `ZStack` overlays controlled by `@State` booleans, not navigation destinations.

Route cases:

| Route | Parameters | Screen |
|---|---|---|
| `.home` | — | `HomeScreen` |
| `.limeRoom(boardName:)` | `String` | `LimeRoomScreen` |
| `.boardPost(boardName:, postId:)` | `String, String` | `BoardPostScreen` |
| `.boardPostWrite(boardName:)` | `String` | `BoardPostWriteScreen` |
| `.search` | — | `SearchScreen` |
| `.personalityTest` | — | `PersonalityTestScreen` |
| `.personalityTestResult` | — | `PersonalityTestResultScreen` |
| `.login` | — | `LoginScreen` |
| `.signUp` | — | `SignUpScreen` |
| `.verifyEmail` | — | `VerifyEmailScreen` |
| `.psyTestList` | — | `PsyTestListScreen` |
| `.userCurrentPosts` | — | `UserCurrentPostsScreen` |
| `.userCurrentComments` | — | `UserCurrentCommentsScreen` |
| `.appSettings` | — | `AppSettingsScreen` |
| `.profileSettings` | — | `ProfileSettingsScreen` |
| `.forgotPassword` | — | `ForgotPasswordScreen` |
| `.changePassword` | — | `ChangePasswordScreen` |
| `.trendSearchResult(keyword:)` | `String` | `TrendSearchResultScreen` |
| `.report(boardName:, postId:)` | `String, String` | `ReportScreen` |
| `.notifications` | — | `NotificationsScreen` |

### ViewModels

All use `@Observable` (iOS 17+), never `ObservableObject`. Each has a protocol + `Impl` class.

| ViewModel | Dependencies |
|---|---|
| `HomeViewModel` | `RealTimeRepository`, `BoardRepository`, `UserRepository`, `AuthRepository` |
| `HomeLimesTodayViewModel` | `BoardRepository` |
| `SideMenuViewModel` | `CategoryRepository`, `UserRepository` |
| `ProfileViewModel` | `UserRepository`, `PersonalityTestRepository`, `AuthRepository` |
| `LimeRoomViewModel` | `UCGetLimeRoomMeta`, `UCGetLimeRoomPostList`, `UserRepository` |
| `BoardPostViewModel` | `UCGetPost`, `UCGetComments`, `UCWriteComment`, `UCRecommendPost` |
| `BoardPostWriteViewModel` | `UCWritePost`, `AuthRepository`, `PostRepository` |
| `UserCurrentPostsViewModel` | `UserRepository`, `AuthRepository` |
| `UserCurrentCommentsViewModel` | `UserRepository`, `AuthRepository` |
| `ProfileSettingsViewModel` | `UserRepository`, `AuthRepository` |
| `SearchViewModel` | `UCSearch` |
| `PersonalityTestViewModel` | `UCRunPsyTest`, `AuthRepository` |
| `ReportViewModel` | `UCReportContent` |
| `ForgotPasswordViewModel` | `AuthRepository` |
| `VerifyEmailViewModel` | `AuthRepository` |
| `ChangePasswordViewModel` | `AuthRepository` |
| `PsyTestListViewModel` | (none) |
| `AppSettingsViewModel` | (none, uses `UserDefaults`) |

### UseCases

| UseCase | Repository Dependencies |
|---|---|
| `UCGetLimeRoomMeta` | `BoardRepository` |
| `UCGetLimeRoomPostList` | `BoardRepository` |
| `UCGetMyLimeRoomMeta` | `UserRepository`, `BoardRepository` |
| `UCGetMyLimeRoomPostList` | `BoardRepository`, `UserRepository` |
| `UCGetPost` | `PostRepository` |
| `UCWritePost` | `PostRepository` |
| `UCGetComments` | `PostRepository` |
| `UCWriteComment` | `PostRepository` |
| `UCRecommendPost` | `PostRepository` |
| `UCReportContent` | `ReportRepository` |
| `UCSearch` | `SearchRepository` |
| `UCRunPsyTest` | `QuestionsRepository`, `PersonalityTestRepository` |

### Repositories

All follow the `Protocol + Impl` pattern. Each `Impl` takes `DataSource` via constructor injection.

`AppStateRepository`, `UserRepository`, `RealTimeRepository`, `CategoryRepository`, `BoardRepository`, `BoardListRepository`, `PostRepository`, `PersonalityTestRepository`, `QuestionsRepository`, `SearchRepository`, `ReportRepository`, `AuthRepository`

Note: `AuthRepository` impl (`FirebaseAuthRepository`) lives in `Data/` and uses Firebase Auth directly rather than `DataSource`.

## Import Rules

| Layer | Allowed imports |
|---|---|
| Entities, Models, Repositories, UseCases, ViewModels | `Foundation` only |
| `SomLimeColors.swift`, `SomLimeFonts.swift` | `UIKit` + `SwiftUI` |
| `Data/` layer (incl. `FirebaseAuthRepository`) | `Firebase`, `SQLite`, `UIKit` |
| SwiftUI Views | `SwiftUI` |

Entities and ViewModels must **never** import UIKit or Firebase.

## Data Layer Boundary

Firebase `Timestamp` values are converted to `String` at the `FirebaseDataSource` boundary via `convertTimestamps()`. Code above the data layer never handles Firebase types.

Post creation uses `FieldValue.serverTimestamp()` for `PublishedTime` to ensure proper Firestore ordering.

`SQLiteDatabaseCommands` uses static methods that accept a `database: Connection?` parameter — the connection is initialized in `SomlimeeApp` and passed down, not stored globally.

## Firestore Collections

```
Users/{uid}
  ├── UserName, SignUpDate, Points, NumOfPosts, ReceivedUps, DaysOfActive
  ├── PersonalityTestResult: [Int, Int, Int, Int]   // [S, R, H, C]
  └── PersonalityType: String                        // e.g. "SDR"

BoardInfo/{typeCode}                                 // e.g. "SDR", "HDE"
  ├── Board metadata fields
  └── Posts/{postId}
      ├── Post metadata (Title, UserId, PublishedTime, VoteUps, Views, ...)
      └── BoardPostContents/{postId}
          ├── Content, Title, PublishedTime
          └── Comments/
              └── CommentList/{commentId}

BoardHotPosts/{typeCode}                             // Hot post rankings
RealTime/                                            // Trends, search data
Reports/{reportId}                                   // User-submitted reports
```

Board names are the 15 personality type codes: `SDD, SDR, SDE, CDD, CDR, CDE, RDD, RDR, RDE, HDD, HDR, HDE, NDD, NDR, NDE` (defined in `SomeLiMePTTypeDesc.typeDetail.keys`).

## Patterns to Follow

- **Constructor injection** for all dependencies — no singletons, no service locator
- **Result type** for use case returns: `Result<Entity, Error>`
- **async/await** for all data operations
- **Protocol + Impl** naming: e.g., `UserRepository` (protocol) + `UserRepositoryImpl` (class)
- Use case classes are prefixed `UC`: `UCGetPost`, `UCWritePost`, etc.

## Logging

All layers use the centralized `Log` enum (`CoreBL/Utils/SomLimeLogger.swift`) built on `os.Logger` with subsystem/category pattern.

| Category | Logger | Usage |
|---|---|---|
| Data | `Log.data` | Firebase, SQLite operations |
| Repository | `Log.repo` | Repository method calls |
| UseCase | `Log.useCase` | Business logic execution |
| ViewModel | `Log.vm` | UI state changes, user actions |
| Auth | `Log.auth` | Sign in/out, account operations |
| UI | `Log.ui` | Navigation, screen transitions |
| App | `Log.app` | App lifecycle, initialization |

### Logging Rules

- **Every new method** in Impl classes must include entry + success/error logs
- Read operations use `.debug` level; write/mutating operations use `.info` level
- Error/catch blocks use `.error` level with `error.localizedDescription`
- Include relevant context: method name, key parameters, result counts
- Do NOT add `import os` in non-Data files — `Log` is module-visible
- Data layer files (`Data/`) require `import os` since they are in separate compilation units with Firebase/SQLite
- Filter in Console.app: `subsystem: com.borkenchj.Somlimee`, `category: Data | Repository | UseCase | ViewModel | Auth | UI | App`

## File Structure

```
Somlimee/
  SomlimeeApp.swift                      # @main entry, FirebaseApp.configure(), DI, SQLite init
  GoogleService-Info.plist               # Firebase config
  SwiftUIViews/
    RootView.swift                       # NavigationStack + ZStack drawer overlays
    Navigation/Route.swift               # 20-case Route enum
    Screens/ (22 files)                  # Full-page screens + overlay panels
    Components/ (18 files)               # Reusable UI components
  Entities/ (25 files)                   # Domain models (Foundation only)
  Models/ (14 files)                     # DTOs for data layer
  Data/ (8 files)                        # DataSource protocols + Firebase/SQLite impls
    DataSource.swift                     # Unified protocol (22 methods)
    RemoteDataSource.swift               # Firebase protocol (18 methods)
    LocalDataSource.swift                # SQLite protocol (5 methods)
    FirebaseSQLiteDataSource.swift       # Composed impl
    FirebaseDataSource.swift             # Firestore impl
    SQLiteDataSource.swift               # SQLite impl
    SQLiteDatabaseCommands.swift         # Static SQLite helpers
    FirebaseAuthRepository.swift         # Auth impl (lives in Data/)
  Repositories/ (12 files)              # Protocol + Impl pairs
  UseCases/ (12 files)                  # Business logic, UC-prefixed
  ViewModels/ (18 files)                # @Observable, protocol + Impl
  CoreBL/
    Failure.swift                        # Base failure protocol
    Failures/ (10 files)                 # Typed error enums
    Functions/
      LocalDataSourceInit.swift          # SQLite table creation + seed data
      CalculateTestResult.swift          # Personality test scoring
      userNameParser.swift               # (unused dead code)
    Utils/
      DictionaryDecoder.swift            # Dict → Codable helper
      Configurations/
        DIContainer.swift                # All Swinject registrations
        DIEnvironment.swift              # SwiftUI EnvironmentKey
        SomLimeColors.swift              # Color tokens (UIKit + SwiftUI)
        SomLimeFonts.swift               # SpoqaHanSansNeo font scale
        SomeLiMePTTypeDesc.swift         # 15 personality type descriptions
        SomLiMeTestBeta.swift            # Test question data
```

## Key Files

- `SomlimeeApp.swift` — `@main` entry point, `FirebaseApp.configure()`, DI setup, SQLite init
- `CoreBL/Utils/Configurations/DIContainer.swift` — all Swinject registrations (4 container-scoped, rest transient)
- `CoreBL/Utils/Configurations/DIEnvironment.swift` — SwiftUI `EnvironmentKey` for DI container
- `SwiftUIViews/RootView.swift` — `NavigationStack` + `ZStack` drawer overlays
- `SwiftUIViews/Navigation/Route.swift` — 20-case type-safe route enum
- `Data/FirebaseSQLiteDataSource.swift` — composed data source (remote + local)
- `Data/FirebaseDataSource.swift` — all Firestore read/write operations
- `CoreBL/Functions/LocalDataSourceInit.swift` — SQLite table creation and seeding
- `CoreBL/Utils/Configurations/SomeLiMePTTypeDesc.swift` — personality type codes and descriptions

## Firestore Security Rules

Defined in `firestore.rules`. Key rules:
- Users: read/write only own document (`request.auth.uid == userId`)
- Board posts: read by anyone auth'd, create by auth'd, update by auth'd (for vote transactions)
- Comments: read/create by auth'd users
- Reports: create-only by auth'd users

Deploy with: `firebase deploy --only firestore:rules`

## Requirements-First Workflow

Feature and screen changes must follow the requirements-first workflow defined in the `requirements-first` skill (`.claude/skills/requirements-first/SKILL.md`). The order is:

1. **Read** the relevant requirement doc in `docs/requirements/`
2. **Update** the requirement doc to reflect the planned change
3. **Implement** the code

Requirement docs (`docs/requirements/01-AUTH.md` through `09-SETTINGS.md`) are the source of truth for feature scope, data flows, ViewModel interfaces, and implementation status. Always consult them before modifying features.

## Design System

The `designing-ui` skill (`.claude/skills/designing-ui/SKILL.md`) defines the complete design system: color tokens, SpoqaHanSansNeo typography with Dynamic Type, 8pt spacing grid, accessibility labels, component patterns, and Korean localization rules. Follow it when creating or modifying any SwiftUI view.

## Development Workflow

6단계 개발 워크플로우. 각 단계에서 해당 스킬을 참조.

```
1. Requirements (요구사항)
   ├── docs/requirements/ 문서 확인 및 업데이트
   ├── 기능 범위, 데이터 흐름, ViewModel 인터페이스 정의
   └── Skill: requirements-first

2. Design (디자인)
   ├── 디자인 시스템 토큰 적용 (색상, 타이포, 간격)
   ├── 접근성 + HIG 준수 확인
   └── Skill: designing-ui

3. Development (개발)
   ├── feature/ 브랜치 생성 (git-workflow)
   ├── Clean Architecture 레이어별 구현
   ├── 로깅: Log.{data|repo|useCase|vm|auth|ui|app} (SomLimeLogger)
   ├── 에러 핸들링: Result<T, Failure> 패턴 (error-monitoring)
   ├── 미완성 기능: #if DEBUG 또는 Remote Config (feature-toggle)
   └── Skills: git-workflow, error-monitoring, feature-toggle

4. Code Review (코드 리뷰)
   ├── 아키텍처 경계, import 규칙, DI 패턴 검증
   ├── 디자인 시스템 준수, 접근성 확인
   └── Skill: code-review

5. QA Testing (테스트)
   ├── ViewModel/UseCase/Repository 단위 테스트
   ├── Mock 기반 프로토콜 테스트, Given/When/Then
   └── Skill: qa-testing

6. Deployment (배포)
   ├── Firebase rules 배포, Release 빌드 검증
   ├── TestFlight → App Store 제출
   └── Skill: deployment-checklist
```

## Skills

Project skills in `.claude/skills/` enforce workflows and standards:

| Skill | Phase | Purpose | When to Use |
|---|---|---|---|
| `requirements-first` | 1. Requirements | 요구사항 우선 워크플로우 | 기능 추가/수정 전 |
| `designing-ui` | 2. Design | 디자인 시스템 + HIG + 접근성 | SwiftUI 뷰 작성/수정 |
| `git-workflow` | 3. Development | 브랜칭 전략, 커밋 규칙, PR 템플릿 | 브랜치 생성, 커밋, PR |
| `error-monitoring` | 3. Development | 에러 핸들링, Failure 타입, Crashlytics | 에러 처리 구현 |
| `feature-toggle` | 3. Development | 기능 플래그, Remote Config, 롤아웃 | 미완성 기능 관리 |
| `code-review` | 4. Code Review | 아키텍처/DI/디자인 준수 체크리스트 | PR 리뷰, 코드 감사 |
| `qa-testing` | 5. QA Testing | 테스트 전략, Mock 패턴, 커버리지 | 테스트 작성, 리뷰 |
| `deployment-checklist` | 6. Deployment | Firebase 배포, App Store 제출 | 릴리스 준비 |
