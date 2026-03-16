# Logging Enforcer Memory

## Completed Instrumentation (Feb 2026)

### UseCases (12 files) — ALL INSTRUMENTED
All UseCase implementation files now have structured logging using `Log.useCase`:
- Entry logging with parameters (`.debug` for reads, `.info` for writes)
- Success logging with result summaries
- Error logging in all catch blocks
- Privacy labels: `.private` for user IDs/emails, `.public` for operation names

Files:
1. UCGetLimeRoomMeta.swift
2. UCGetLimeRoomPostList.swift
3. UCGetMyLimeRoomMeta.swift
4. UCGetMyLimeRoomPostList.swift
5. UCGetPost.swift (2 methods: getPostMeta, getPostContent)
6. UCWritePost.swift
7. UCGetComments.swift
8. UCWriteComment.swift
9. UCRecommendPost.swift
10. UCReportContent.swift
11. UCSearch.swift (2 methods: execute, getAvailableBoards)
12. UCRunPsyTest.swift (3 methods: loadQuestions, calculateResult, saveResult)

### ViewModels (19 files) — ALL INSTRUMENTED
All ViewModel implementation files now have structured logging using `Log.vm`:
- Method entry logging (`.debug` for loads, `.info` for user actions)
- Success logging with data summaries (e.g., "loaded N items")
- Error logging in all catch blocks
- State transition logging where applicable

Files:
1. HomeViewModel.swift (7 methods)
2. HomeLimesTodayViewModel.swift
3. SideMenuViewModel.swift
4. ProfileViewModel.swift (4 methods including signOut)
5. LimeRoomViewModel.swift
6. BoardPostViewModel.swift (4 methods: loadPost, loadComments, submitComment, voteUp)
7. BoardPostWriteViewModel.swift (2 methods: removeImage, submitPost)
8. UserCurrentPostsViewModel.swift
9. UserCurrentCommentsViewModel.swift
10. ProfileSettingsViewModel.swift (3 methods: loadProfile, updateNickname, deleteAccount)
11. SearchViewModel.swift (2 methods: loadBoards, search)
12. PersonalityTestViewModel.swift (4 methods: loadQuestions, selectAnswer, goBack, finishTest)
13. ReportViewModel.swift
14. ForgotPasswordViewModel.swift
15. VerifyEmailViewModel.swift (2 methods)
16. ChangePasswordViewModel.swift
17. PsyTestListViewModel.swift
18. AppSettingsViewModel.swift (2 methods: loadSettings, saveSettings)
19. NotificationViewModel.swift (3 methods: loadNotifications, markAsRead, markAllAsRead)

## Logger Implementation

Location: `/Users/user/development/swift/Somlimee/Somlimee/CoreBL/Utils/SomLimeLogger.swift`

Structure:
```swift
enum Log {
    static let data = Logger(subsystem: "com.borkenchj.Somlimee", category: "Data")
    static let repo = Logger(subsystem: "com.borkenchj.Somlimee", category: "Repository")
    static let useCase = Logger(subsystem: "com.borkenchj.Somlimee", category: "UseCase")
    static let vm = Logger(subsystem: "com.borkenchj.Somlimee", category: "ViewModel")
    static let auth = Logger(subsystem: "com.borkenchj.Somlimee", category: "Auth")
    static let ui = Logger(subsystem: "com.borkenchj.Somlimee", category: "UI")
    static let app = Logger(subsystem: "com.borkenchj.Somlimee", category: "App")
}
```

## Logging Patterns Used

### UseCase Pattern
```swift
func execute(params) async -> Result<T, Error> {
    Log.useCase.debug("[read] UCName.methodName: param=\(param, privacy: .public)")
    // OR
    Log.useCase.info("[write] UCName.methodName: param=\(param, privacy: .public)")

    do {
        // ... business logic
        Log.useCase.debug("UCName.methodName: success — summary")
        return .success(data)
    } catch {
        Log.useCase.error("UCName.methodName: failed — \(error)")
        return .failure(error)
    }
}
```

### ViewModel Pattern
```swift
func loadData() async {
    Log.vm.debug("ViewModelName.methodName: start")
    // ... async operation
    Log.vm.debug("ViewModelName.methodName: success — N items")
}

func submitAction() async {
    Log.vm.info("ViewModelName.methodName: user action")
    // ... mutation
    Log.vm.info("ViewModelName.methodName: success")
}
```

## Key Decisions

1. **No `import os` needed** — The `Log` enum is in the same module (Somlimee), so UseCases and ViewModels can access it without importing.

2. **Privacy labels**:
   - `.private` for user IDs, emails, names, personality types
   - `.public` for board names, operation types, counts, status codes

3. **Log levels**:
   - `.debug` — Read operations, state queries, internal flow
   - `.info` — Write operations, user actions, significant state changes
   - `.error` — All failures in catch blocks

4. **Message format**: `"ClassName.methodName: context"` for traceability

### Repositories (12 files) — ALL INSTRUMENTED (Feb 16, 2026)
All Repository implementation files now have structured logging using `Log.repo`:
- Entry logging with parameters (`.debug` for reads, `.info` for writes)
- Success logging with result counts/summaries
- Error logging in all catch blocks
- Privacy labels: `.private` for user IDs/emails/postIds, `.public` for board names/counts

Files:
1. AppStateRepository.swift (2 methods)
2. BoardListRepository.swift (1 method)
3. BoardRepository.swift (2 methods)
4. CategoryRepository.swift (1 method)
5. PersonalityTestRepository.swift (2 methods)
6. PostRepository.swift (7 methods)
7. QuestionRepository.swift (1 method)
8. RealTimeRepository.swift (2 methods)
9. SearchRepository.swift (2 methods)
10. UserRepository.swift (7 methods)
11. ReportRepository.swift (1 method)
12. NotificationRepository.swift (2 methods)

Total: 30 repository methods instrumented

## Not Instrumented Yet

- **Data Layer** (8 files) — Firebase/SQLite operations, need network/DB operation logging
- **SwiftUI Views** — Screen appearances, navigation events (avoid rapid UI updates)

## Common Patterns Found

- Most ViewModels have `isLoading` flag toggling
- Error handling via `errorMessage: String?` property
- UseCase methods return `Result<T, Error>`
- Many ViewModels check `authRepo.isLoggedIn` or `currentUserID`

## Gotchas

- `userNameParser.swift` in CoreBL/Functions/ is dead code (not used anywhere)
- Some ViewModels use `try?` to suppress errors — these won't trigger error logging in the repo/data layers
- **Enum interpolation**: Swift enums that don't conform to `CustomStringConvertible` cause compilation failures when directly interpolated in logger calls (e.g., `SearchScope` enum) — either omit from log or convert to string first
