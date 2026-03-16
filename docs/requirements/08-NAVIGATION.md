# 08. 네비게이션 (Navigation)

## 개요

앱 전체 네비게이션 구조. `NavigationStack` + `Route` enum 기반 타입-세이프 라우팅. 사이드 메뉴와 프로필 패널은 `ZStack` 오버레이로 구현한다.

---

## F-NAV-01: 루트 뷰 (RootView)

**화면**: `RootView`
**파일**: `SwiftUIViews/RootView.swift`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| NAV-01-01 | `NavigationStack`으로 전체 화면 라우팅 관리 | P0 | 구현됨 |
| NAV-01-02 | `HomeScreen`을 기본(root) 화면으로 표시 | P0 | 구현됨 |
| NAV-01-03 | `Route` enum 기반 `navigationDestination` 등록 | P0 | 구현됨 |
| NAV-01-04 | 사이드 메뉴: 좌측 슬라이드 오버레이 (ZStack) | P0 | 구현됨 |
| NAV-01-05 | 프로필 패널: 우측 슬라이드 오버레이 (ZStack) | P0 | 구현됨 |
| NAV-01-06 | 오버레이 열릴 때 배경 딤 처리 | P1 | 구현됨 |
| NAV-01-07 | 딤 영역 탭 시 오버레이 닫기 | P1 | 구현됨 |
| NAV-01-08 | 슬라이드 애니메이션 적용 | P1 | 구현됨 |

### 구조

```
ZStack {
  NavigationStack(path: $path) {
    HomeScreen(...)
      .navigationDestination(for: Route.self) { ... }
  }

  // 딤 오버레이
  if showSideMenu || showProfile {
    Color.black.opacity(0.3)
      .onTapGesture { closeOverlays() }
  }

  // 사이드 메뉴 (좌측)
  SideMenuPanel(...)
    .frame(width: 280)
    .offset(x: showSideMenu ? 0 : -280)

  // 프로필 패널 (우측)
  ProfilePanel(...)
    .frame(width: 300)
    .offset(x: showProfile ? 0 : 300)
}
```

---

## F-NAV-02: Route Enum

**파일**: `SwiftUIViews/Navigation/Route.swift`

### Route 목록

| Route | 파라미터 | 대상 화면 |
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

### Route 규칙

- `Route: Hashable` 프로토콜 준수 (NavigationStack 요구사항)
- 모든 Route는 `RootView`의 `navigationDestination`에서 처리
- 오버레이(사이드 메뉴, 프로필 패널)는 Route가 아닌 `@State` boolean으로 제어

---

## F-NAV-03: 사이드 메뉴

**화면**: `SideMenuPanel`
**ViewModel**: `SideMenuViewModel`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| NAV-03-01 | 성격 유형 라임방 메뉴 항목 (동적, 15개 유형) | P0 | 구현됨 |
| NAV-03-02 | 커뮤니티 메뉴: 검색, 트렌드, 테스트 목록 | P0 | 구현됨 |
| NAV-03-03 | 활동 메뉴 (로그인 시): 내 게시글, 내 댓글 | P1 | 구현됨 |
| NAV-03-04 | 설정 메뉴: 앱 설정, 프로필 설정 | P1 | 구현됨 |
| NAV-03-05 | 알림 메뉴: 알림 화면 이동 | P1 | 구현됨 |
| NAV-03-06 | 메뉴 항목 탭 시 해당 Route로 네비게이션 후 메뉴 닫기 | P0 | 구현됨 |
| NAV-03-07 | 로그인 상태에 따라 활동 메뉴 표시/숨김 | P1 | 구현됨 |

### 데이터 흐름

```
SideMenuViewModel.loadMenuList()
  → CategoryRepository.getCategoryData()
  → DataSource.getCategoryData()  // SQLite 또는 로컬

SideMenuViewModel.loadIsLoggedIn()
  → UserRepository.isUserLoggedIn()
```

---

## F-NAV-04: 알림

**화면**: `NotificationsScreen`
**Route**: `.notifications`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| NAV-04-01 | 알림 목록 표시 (댓글, 답글, 추천, 언급) | P2 | 미구현 (UI만) |
| NAV-04-02 | 알림 필터 탭: 전체, 댓글, 추천, 언급 | P2 | 구현됨 |
| NAV-04-03 | "모두 읽음" 버튼 | P2 | 구현됨 |
| NAV-04-04 | 알림 탭 시 해당 게시글 이동 | P2 | 구현됨 |
| NAV-04-05 | 알림 없을 경우 "알림이 없습니다" 빈 상태 표시 | P2 | 구현됨 |
| NAV-04-06 | 백엔드 알림 시스템 연동 | P2 | **미구현** |
| NAV-04-07 | 알림 화면 진입 시 홈 네비게이션 바의 빨간 점 배지 제거 | P1 | 구현됨 |

**참고**: 현재 UI만 구현되어 있으며 `notifications = []`으로 초기화되어 항상 빈 상태를 표시한다. 실제 푸시 알림 또는 Firestore 기반 알림 시스템은 아직 구현되지 않았다. 빨간 점 배지는 백엔드 미연동 상태이므로 표시하지 않는다.

### 알림 데이터 모델 (로컬)

```swift
struct AppNotification: Identifiable {
    let id: String
    let type: NotificationType  // .comment, .reply, .upvote, .mention
    let senderName: String
    let message: String
    let boardName: String
    let postId: String
    let timestamp: String
    var isRead: Bool
}
```

---

## 네비게이션 흐름 다이어그램

```
┌─────────────────────────────────────┐
│           RootView (ZStack)          │
│                                      │
│  ┌──────────────────────────────┐   │
│  │    NavigationStack            │   │
│  │                               │   │
│  │  HomeScreen (root)            │   │
│  │    ├→ LimeRoomScreen          │   │
│  │    │    ├→ BoardPostScreen     │   │
│  │    │    │    └→ ReportScreen   │   │
│  │    │    └→ BoardPostWriteScreen│   │
│  │    ├→ SearchScreen            │   │
│  │    ├→ TrendSearchResultScreen │   │
│  │    ├→ PsyTestListScreen       │   │
│  │    │    └→ PersonalityTestScreen   │
│  │    ├→ PersonalityTestResultScreen  │
│  │    ├→ LoginScreen             │   │
│  │    │    ├→ SignUpScreen        │   │
│  │    │    │    └→ VerifyEmailScreen  │
│  │    │    └→ ForgotPasswordScreen│   │
│  │    ├→ UserCurrentPostsScreen  │   │
│  │    ├→ UserCurrentCommentsScreen│   │
│  │    ├→ ProfileSettingsScreen   │   │
│  │    │    └→ ChangePasswordScreen│   │
│  │    ├→ AppSettingsScreen       │   │
│  │    └→ NotificationsScreen     │   │
│  └──────────────────────────────┘   │
│                                      │
│  ┌──────────┐    ┌──────────────┐   │
│  │SideMenu  │    │ProfilePanel  │   │
│  │(overlay) │    │(overlay)     │   │
│  └──────────┘    └──────────────┘   │
└─────────────────────────────────────┘
```
