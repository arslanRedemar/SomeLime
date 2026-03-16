---
name: error-monitoring
description: Error handling patterns, Failure types, logging standards, and crash monitoring for the Somlimee project. Enforces proper error propagation through Clean Architecture layers, user-facing error messages, and Firebase Crashlytics integration. Use when implementing error handling, reviewing catch blocks, or setting up monitoring.
---

# Error Monitoring

Somlimee 프로젝트 에러 핸들링 패턴. Clean Architecture 레이어별 에러 전파, 사용자 메시지, Crashlytics 연동.

## Error Flow

```
DataSource (throws)
  → Repository (throws / rethrows)
    → UseCase (returns Result<T, Error>)
      → ViewModel (sets errorMessage)
        → View (displays error banner)
```

## Layer-Specific Patterns

### DataSource Layer

Firebase/SQLite 에러를 그대로 throw. 변환하지 않음.

```swift
func getBoardPostMetaList(boardName: String, ...) async throws -> [[String: Any]] {
    let snapshot = try await db.collection("BoardInfo")
        .document(boardName)
        .collection("BoardPostContents")
        .getDocuments()
    return snapshot.documents.map { $0.data() }
}
```

### Repository Layer

DataSource 에러를 catch하여 도메인 에러로 변환하거나 rethrow.

```swift
func getPostContent(boardName: String, postId: String) async throws -> BoardPostContentData? {
    do {
        let data = try await dataSource.getBoardPostContent(boardName: boardName, postId: postId)
        return BoardPostContentData(from: data)
    } catch {
        throw error  // rethrow — UseCase에서 처리
    }
}
```

### UseCase Layer

**반드시 Result 타입 반환.** try? 금지.

```swift
// GOOD
func execute(boardName: String, postId: String) async -> Result<LimeRoomPostContent, UCGetPostFailure> {
    do {
        guard let meta = try await postRepository.getPostMeta(boardName: boardName, postId: postId) else {
            return .failure(.postNotFound)
        }
        guard let content = try await postRepository.getPostContent(boardName: boardName, postId: postId) else {
            return .failure(.contentNotFound)
        }
        return .success(LimeRoomPostContent(paragraph: content.paragraph, imageURLs: content.imageURLs))
    } catch {
        return .failure(.networkError)
    }
}

// BAD — 에러 삼킴
func execute(...) async -> LimeRoomPostContent? {
    return try? await postRepository.getPostContent(...)  // 금지!
}
```

### ViewModel Layer

Result를 처리하여 사용자 메시지 설정. **모든 catch에서 errorMessage 설정 필수.**

```swift
func loadPost(boardName: String, postId: String) async {
    isLoading = true
    defer { isLoading = false }

    let result = await ucGetPost.execute(boardName: boardName, postId: postId)
    switch result {
    case .success(let content):
        self.content = content
        self.errorMessage = nil
    case .failure(let failure):
        self.errorMessage = failure.userMessage
    }
}
```

### View Layer

ViewModel의 errorMessage를 표시.

```swift
if let error = vm?.errorMessage {
    Text(error)
        .font(.hanSansNeoRegular(size: 13))
        .foregroundStyle(.red.opacity(0.8))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
}
```

## Failure Types

`CoreBL/Failures/` 디렉토리에 UseCase별 Failure enum 정의.

### 구조

```swift
import Foundation

enum UCGetPostFailure: Error, LocalizedError {
    case postNotFound
    case contentNotFound
    case networkError
    case unauthorized

    var userMessage: String {
        switch self {
        case .postNotFound:     return "게시글을 찾을 수 없습니다"
        case .contentNotFound:  return "게시글 내용을 불러올 수 없습니다"
        case .networkError:     return "네트워크 오류가 발생했습니다"
        case .unauthorized:     return "로그인이 필요합니다"
        }
    }
}
```

### Naming Convention

| UseCase | Failure Type |
|---|---|
| UCGetPost | UCGetPostFailure |
| UCWritePost | UCWritePostFailure |
| UCGetLimeRoomPostList | UCGetLimeRoomPostListFailure |
| UCSearch | UCSearchFailure |

### userMessage Rules

- 한국어
- 사용자가 이해할 수 있는 언어 (기술 용어 금지)
- 가능하면 해결 방법 제시

| 유형 | 예시 |
|---|---|
| 네트워크 | "네트워크 오류가 발생했습니다. 연결 상태를 확인해주세요" |
| 인증 | "로그인이 필요합니다" |
| 미발견 | "게시글을 찾을 수 없습니다" |
| 권한 | "이 작업을 수행할 권한이 없습니다" |
| 입력 | "제목을 입력해주세요" |
| 서버 | "일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요" |

## Anti-Patterns

### try? (에러 삼킴) 금지

```swift
// BAD
let data = try? await repo.getData()  // 에러 사라짐

// GOOD
do {
    let data = try await repo.getData()
} catch {
    errorMessage = "데이터를 불러올 수 없습니다"
}
```

### 빈 catch 금지

```swift
// BAD
} catch {
    // nothing — 에러 무시
}

// GOOD
} catch {
    errorMessage = "오류가 발생했습니다"
}
```

### print 디버깅 금지 (Release)

```swift
// BAD
} catch {
    print("Error: \(error)")  // Release에서 의미 없음
}

// GOOD
} catch {
    #if DEBUG
    print("Error: \(error)")
    #endif
    errorMessage = error.localizedDescription
}
```

## Firebase Crashlytics Integration

### 설정

```swift
// SomlimeeApp.swift
import FirebaseCrashlytics

@main
struct SomlimeeApp: App {
    init() {
        FirebaseApp.configure()
        #if !DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        #endif
    }
}
```

### Non-Fatal Error 리포트

심각하지 않지만 추적이 필요한 에러:

```swift
// Repository 또는 UseCase에서
} catch {
    #if !DEBUG
    Crashlytics.crashlytics().record(error: error, userInfo: [
        "context": "loadPost",
        "boardName": boardName,
        "postId": postId
    ])
    #endif
    return .failure(.networkError)
}
```

### Custom Keys

```swift
Crashlytics.crashlytics().setCustomValue(boardName, forKey: "last_board")
Crashlytics.crashlytics().setUserID(userId)
```

## Error Visibility Checklist

모든 ViewModel은 에러를 사용자에게 표시해야 함:

```
[ ] errorMessage: String? 프로퍼티 존재
[ ] 모든 catch 블록에서 errorMessage 설정
[ ] View에서 errorMessage 표시 UI 존재
[ ] 성공 시 errorMessage = nil 설정
[ ] isLoading 상태와 에러 상태 동시 관리
```

## Rules

**DO:**
- UseCase에서 `Result<T, Failure>` 반환
- 모든 catch에서 `errorMessage` 설정
- Failure enum에 `userMessage` 한국어 제공
- `#if DEBUG`로 디버그 출력 감싸기
- Non-fatal 에러 Crashlytics에 리포트

**DON'T:**
- `try?` 사용 (에러 삼킴)
- 빈 catch 블록
- 기술 용어로 사용자 메시지 작성 ("NSError", "timeout", "404")
- Release 빌드에 `print()` 남기기
- 에러를 ViewModel에서 무시
