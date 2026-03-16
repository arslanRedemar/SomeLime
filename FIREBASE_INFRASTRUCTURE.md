# Somlimee Firebase Infrastructure

> **Project**: SomLiMe
> **Project ID**: `somlime-47d80`
> **Project Number**: `103297096033`
> **Region**: `asia-northeast3` (Seoul)
> **State**: ACTIVE
> **Created**: 2023-03-30
> **Account**: brokenchj@gmail.com

---

## 1. Registered Apps

| Platform | App ID | Bundle ID | Display Name | Status |
|----------|--------|-----------|--------------|--------|
| iOS | `1:103297096033:ios:c446a9a4d0114bf5b1cd20` | `com.borkenchj.Somlimee` | SomLiMe | ACTIVE |

> Android/Web 앱 미등록. iOS 단일 플랫폼.

---

## 2. Firebase Services 사용 현황

| Service | 사용 여부 | 비고 |
|---------|----------|------|
| **Authentication** | O | Email/Password |
| **Cloud Firestore** | O | 주 원격 데이터베이스 |
| **Storage** | O (설정만) | `somlime-47d80.appspot.com` |
| **Analytics** | X | `IS_ANALYTICS_ENABLED: false` |
| **Cloud Messaging (GCM)** | O (설정만) | `IS_GCM_ENABLED: true` |
| **App Invites** | O (설정만) | `IS_APPINVITE_ENABLED: true` |
| **Hosting** | O (설정만) | `somlime-47d80` site |
| **Ads** | X | `IS_ADS_ENABLED: false` |

---

## 3. Firebase Authentication

### 인증 방식
- **Email/Password** 인증 (`IS_SIGNIN_ENABLED: true`)

### 구현 (`FirebaseAuthRepository.swift`)

| 기능 | 메서드 | 설명 |
|------|--------|------|
| 로그인 | `signIn(email:password:)` | `Auth.auth().signIn()` |
| 로그아웃 | `signOut()` | `Auth.auth().signOut()` |
| 회원가입 | `createUser(email:password:)` | `Auth.auth().createUser()` |
| 이메일 인증 | `sendEmailVerification()` | 인증 메일 발송 |
| 사용자 리로드 | `reloadCurrentUser()` | 최신 상태 반영 |
| 상태 리스너 | `addAuthStateListener(_:)` | 로그인 상태 변경 감지 |
| 로그인 상태 확인 | `isLoggedIn` (computed) | `currentUser != nil` |
| 현재 UID | `currentUserID` (computed) | `currentUser?.uid` |

---

## 4. Cloud Firestore - 컬렉션 구조

### 4.1 `RealTime` (루트 컬렉션)

실시간 트렌드 데이터를 저장합니다.

```
RealTime/
  └── RTLimeTrends          # Document
        └── trendsList: [String]
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `trendsList` | `[String]` | 실시간 트렌드 키워드 목록 |

**사용**: `FirebaseDataSource.getLimeTrendsData()` → `LimeTrendsData`

---

### 4.2 `Users` (루트 컬렉션)

사용자 프로필 정보를 저장합니다. 문서 ID는 Firebase Auth UID입니다.

```
Users/
  └── {uid}                  # Document (Auth UID)
        ├── UserName: String
        ├── profileImageURL: String?
        ├── totalUps: Int
        ├── signUpDate: String (Timestamp → String 변환)
        ├── numOfPosts: Int
        ├── receivedUps: Int
        ├── points: Int
        ├── daysOfActive: Int
        ├── badges: [String]
        ├── personalityTestResult: Map
        │     ├── Strenuousness: Int
        │     ├── Receptiveness: Int
        │     ├── Harmonization: Int
        │     └── Coagulation: Int
        └── personalityType: String
```

**사용**:
- READ: `FirebaseDataSource.getUserData()` → `ProfileData`
- WRITE: `FirebaseDataSource.updateUser(userInfo:)` (전체 문서 덮어쓰기)

---

### 4.3 `BoardInfo` (루트 컬렉션)

라임룸(게시판) 정보와 게시글을 저장합니다. 문서 ID에서 `/` 문자는 제거됩니다.

```
BoardInfo/
  └── {boardName}            # Document (boardName에서 "/" 제거)
        ├── boardName: String
        ├── boardOwnerID: String
        ├── tapList: [String]          # 카테고리 탭 목록
        ├── boardLevel: Int
        ├── boardDescription: String
        ├── boardHotKeyword: [String]
        │
        └── Posts/                     # Subcollection
              └── {postId}             # Document (auto-generated)
                    ├── BoardTap: String
                    ├── CommentsNumber: Int
                    ├── PostTitle: String
                    ├── PostType: String        # "text" | "image"
                    ├── PublishedTime: String    # Timestamp → String
                    ├── ThumbnailURL: String
                    ├── UserId: String
                    ├── UserName: String
                    ├── Views: Int
                    ├── VoteUps: Int
                    │
                    └── BoardPostContents/      # Subcollection
                          ├── Paragraph          # Document (고정 ID)
                          │     └── Text: String
                          ├── Image              # Document (고정 ID)
                          │     └── URLs: [String]
                          ├── Video              # Document (고정 ID)
                          │     └── URLs: [String]
                          └── Comments           # Document (고정 ID)
                                └── {commentId}  # Subcollection (addDocument)
                                      ├── Text: String
                                      ├── Target: String
                                      ├── PublishedTime: String
                                      └── IsRevised: String   # "No" | "Yes"
```

**사용**:
- Board 정보: `getBoardInfoData(boardName:)` → `BoardInfoData`
- 게시글 목록: `getBoardPostMetaList(boardName:startTime:counts:)` → `[BoardPostMetaData]`
- 게시글 상세: `getBoardPostMeta(boardName:postId:)` → `BoardPostMetaData`
- 게시글 내용: `getBoardPostContent(boardName:postId:)` → `BoardPostContentData`
- 게시글 작성: `createPost(boardName:postData:)`
- 댓글 작성: `writeComment(boardName:postId:target:text:)`

**쿼리 패턴**:
- `PublishedTime` 기준 내림차순 정렬
- `startTime`으로 시간 필터링 (`whereField("PublishedTime", isGreaterThanOrEqualTo:)`)
- `counts`로 페이징 (`limit(to:)`)

---

### 4.4 `BoardHotPosts` (루트 컬렉션)

인기 게시글 목록을 별도로 관리합니다. `BoardInfo`와 동일한 boardName 키를 사용합니다.

```
BoardHotPosts/
  └── {boardName}            # Document
        └── Posts/           # Subcollection
              └── {postId}   # Document
                    └── PublishedTime: String
```

**사용**: `getBoardHotPostsList(boardName:startTime:counts:)` → `[String]` (post ID 목록만 반환)

---

### 4.5 전체 Firestore 경로 요약

| 경로 | 타입 | CRUD | DTO |
|------|------|------|-----|
| `RealTime/RTLimeTrends` | Document | R | `LimeTrendsData` |
| `Users/{uid}` | Document | R/W | `ProfileData` |
| `BoardInfo/{boardName}` | Document | R | `BoardInfoData` |
| `BoardInfo/{boardName}/Posts` | Collection | R/W | `[BoardPostMetaData]` |
| `BoardInfo/{boardName}/Posts/{postId}` | Document | R | `BoardPostMetaData` |
| `BoardInfo/{boardName}/Posts/{postId}/BoardPostContents/Paragraph` | Document | R/W | (Text) |
| `BoardInfo/{boardName}/Posts/{postId}/BoardPostContents/Image` | Document | R/W | (URLs) |
| `BoardInfo/{boardName}/Posts/{postId}/BoardPostContents/Video` | Document | R/W | (URLs) |
| `BoardInfo/{boardName}/Posts/{postId}/BoardPostContents/Comments` | Document+Sub | R/W | `BoardPostCommentData` |
| `BoardHotPosts/{boardName}/Posts` | Collection | R | `[String]` (IDs) |

---

## 5. Firebase Storage

- **Bucket**: `somlime-47d80.appspot.com`
- **현재 사용**: 코드상에서 직접적인 Storage 업로드/다운로드 구현 없음
- 프로필 이미지 URL (`profileImageURL`)과 게시글 이미지 URL은 Firestore 문서에 문자열로 저장됨

---

## 6. Security Rules

### 6.1 Firestore Rules (Updated 2026-02-11)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /RealTime/{document} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    match /Users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if false;
    }
    match /BoardInfo/{boardName} {
      allow read: if request.auth != null;
      allow write: if false;
      match /Posts/{postId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null
          && request.resource.data.UserId == request.auth.uid;
        allow update, delete: if false;
        match /BoardPostContents/{contentId} {
          allow read: if request.auth != null;
          allow create: if request.auth != null;
          allow update, delete: if false;
          match /{commentId} {
            allow read: if request.auth != null;
            allow create: if request.auth != null;
            allow update, delete: if false;
          }
        }
      }
    }
    match /BoardHotPosts/{boardName} {
      allow read: if request.auth != null;
      allow write: if false;
      match /Posts/{postId} {
        allow read: if request.auth != null;
        allow write: if false;
      }
    }
  }
}
```

### 6.2 Storage Rules (Updated 2026-02-11)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.auth.uid == userId
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
    match /posts/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

---

## 7. SQLite (로컬 데이터베이스)

Firebase와 함께 로컬 캐싱에 사용되는 SQLite 데이터베이스입니다.

- **파일 경로**: `Documents/Somlimee.sqlite3`
- **라이브러리**: SQLite.swift (~> 0.14.0)

### 테이블 구조

| 테이블 | 컬럼 | 타입 | 설명 |
|--------|------|------|------|
| `Category` | `categoryName` | `String` | 카테고리 이름 |
| `Board` | `boardName` | `String` | 게시판 이름 |
| `AppStates` | `stateName` | `String` | 상태 키 |
| | `stateValue` | `Bool` | 상태 값 |

### 초기 시드 데이터 (`LocalDataSourceInit.swift`)

최초 실행 시 다음 데이터가 자동 삽입됩니다:

- **Category**: `유머`, `스포츠`, `정치`
- **Board**: `유머`, `스포츠`, `정치`
- **AppStates**: `isFirstTimeLaunched: true`, `isNeedToUpdateLocalDataSource: false`

---

## 8. Data Layer 아키텍처

```
┌──────────────────────────────────────────┐
│           FirebaseSQLiteDataSource        │  ← DataSource 프로토콜 구현
│         (Remote + Local 조합)             │
├──────────────────┬───────────────────────┤
│  FirebaseDataSource  │  SQLiteDataSource  │
│  (Firestore + Auth)  │  (SQLite.swift)    │
├──────────────────┴───────────────────────┤
│         Firebase Cloud / Local DB         │
└──────────────────────────────────────────┘
```

### 데이터 흐름

1. **원격 데이터**: `FirebaseDataSource` → Firestore/Auth 접근
2. **로컬 데이터**: `SQLiteDataSource` → SQLite 파일 접근
3. **조합**: `FirebaseSQLiteDataSource` → 두 데이터소스를 합쳐 `DataSource` 프로토콜 구현
4. **Repository**: `DataSource`를 주입받아 비즈니스 로직에서 사용
5. **경계 변환**: Firebase `Timestamp` → `String` 변환은 `FirebaseDataSource`에서 수행

---

## 9. DTO ↔ Firestore 매핑 요약

| DTO (Models/) | Firestore 컬렉션 | 매핑 방식 |
|---------------|-------------------|-----------|
| `LimeTrendsData` | `RealTime/RTLimeTrends` | `[String: Any]` 딕셔너리 |
| `ProfileData` | `Users/{uid}` | `[String: Any]` 딕셔너리 |
| `BoardInfoData` | `BoardInfo/{boardName}` | `[String: Any]` 딕셔너리 |
| `BoardPostMetaData` | `BoardInfo/{boardName}/Posts/{postId}` | `[String: Any]` 딕셔너리 |
| `BoardPostContentData` | `BoardInfo/.../BoardPostContents/*` | `[[String: Any]]` 배열 |
| `BoardPostCommentData` | `BoardInfo/.../BoardPostContents/Comments` | `[String: Any]` 딕셔너리 |
| `AppStatesData` | *(SQLite only)* | `[String: Bool]` 딕셔너리 |
| `CategoryData` | *(SQLite only)* | `[String: Any]` 딕셔너리 |

> 모든 Firestore ↔ DTO 변환은 타입 안전하지 않은 `[String: Any]` 딕셔너리를 통해 이루어짐.
> `Codable` 미사용 — 향후 리팩토링 대상.

---

## 10. 주의 사항 및 개선 필요 항목

### Critical — RESOLVED

| # | 항목 | 상태 | 설명 |
|---|------|------|------|
| 1 | ~~Firestore Rules 만료~~ | RESOLVED (2026-02-11) | 인증 기반 + 소유권 검증 규칙으로 업데이트 완료 |
| 2 | ~~Storage Rules 만료~~ | RESOLVED (2026-02-11) | 인증 기반 + 파일 크기/타입 제한 규칙으로 업데이트 완료 |

### High Priority — RESOLVED

| # | 항목 | 상태 | 설명 |
|---|------|------|------|
| 3 | ~~`updateUser()`가 `setData()` 사용~~ | RESOLVED | `setData(userInfo, merge: true)` 로 변경 완료 |
| 4 | ~~Board name `/` 제거 로직~~ | RESOLVED | `parseBoardName()` 헬퍼로 중앙화 완료 |
| 5 | ~~`firebase.json` 미설정~~ | RESOLVED | `firebase.json` + `firestore.rules` + `storage.rules` 생성 완료 |

### Medium Priority — RESOLVED

| # | 항목 | 상태 | 설명 |
|---|------|------|------|
| 6 | ~~`[String: Any]` 딕셔너리 매핑~~ | RESOLVED | 모든 DTO에 `Codable` + `CodingKeys` 추가, `DictionaryDecoder` 유틸리티 도입, 7개 Repository 파싱 코드 교체 |
| 7 | ~~`writeComment()`에서 boardName 파싱 누락~~ | RESOLVED | `parseBoardName()` 적용 완료 |
| 8 | ~~`SearchListData.swift` 빈 파일~~ | RESOLVED | 파일 삭제 + pbxproj 참조 제거 완료 |
| 9 | ~~DTO 이름 오타~~ | RESOLVED | `HotBaoardRankingData` → `HotBoardRankingData`, `SearchHistroyData` → `SearchHistoryData` |
| 10 | ~~Storage 업로드 미구현~~ | RESOLVED | `Firebase/Storage` Pod 추가, `uploadImage(data:path:)` 메서드 구현 (DataSource → RemoteDataSource → FirebaseDataSource) |

---

## 11. SDK Config (GoogleService-Info.plist)

| Key | Value |
|-----|-------|
| PROJECT_ID | `somlime-47d80` |
| BUNDLE_ID | `com.borkenchj.Somlimee` |
| GOOGLE_APP_ID | `1:103297096033:ios:c446a9a4d0114bf5b1cd20` |
| GCM_SENDER_ID | `103297096033` |
| STORAGE_BUCKET | `somlime-47d80.appspot.com` |
| IS_SIGNIN_ENABLED | `true` |
| IS_ANALYTICS_ENABLED | `false` |
| IS_ADS_ENABLED | `false` |
| IS_GCM_ENABLED | `true` |
| IS_APPINVITE_ENABLED | `true` |
