---
name: feature-toggle
description: Feature flag patterns for the Somlimee project. Covers compile-time flags, runtime Firebase Remote Config toggles, and progressive rollout strategies. Use when hiding incomplete features, implementing A/B tests, or managing gradual feature rollouts.
---

# Feature Toggle

Somlimee 프로젝트 기능 플래그 패턴. 미완성 기능 숨기기, 점진적 롤아웃, A/B 테스트.

## Toggle Types

| Type | Mechanism | Use Case | Persistence |
|---|---|---|---|
| **Compile-time** | `#if DEBUG` | 개발 중 기능 | 빌드 시 결정 |
| **Build Config** | Custom Build Settings | 환경별 기능 | 빌드 시 결정 |
| **Runtime** | Firebase Remote Config | 서버 제어 롤아웃 | 앱 실행 시 결정 |
| **Local** | UserDefaults | 사용자 설정 | 기기에 저장 |

## Compile-Time Flags

### #if DEBUG

개발/테스트 전용 기능에 사용. Release 빌드에서 완전 제거됨.

```swift
#if DEBUG
NavigationLink(value: Route.debugPanel) {
    Text("디버그 패널")
}
#endif
```

### Custom Compilation Conditions

Xcode → Build Settings → Swift Compiler → Active Compilation Conditions에 추가.

```swift
// BETA 빌드에서만 활성화
#if BETA
LimeTestSection(testList: vm?.psyTestList?.list ?? [], showExperimental: true)
#else
LimeTestSection(testList: vm?.psyTestList?.list ?? [])
#endif
```

## Firebase Remote Config

### Setup

```swift
import FirebaseRemoteConfig

final class FeatureFlags {
    static let shared = RemoteConfig.remoteConfig()

    static func configure() {
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0  // 개발 중 즉시 반영
        #else
        settings.minimumFetchInterval = 3600  // 프로덕션: 1시간
        #endif
        shared.configSettings = settings

        // 기본값 설정
        shared.setDefaults([
            "enable_notifications": false as NSObject,
            "enable_search_v2": false as NSObject,
            "enable_bookmark": false as NSObject,
            "max_image_attachments": 5 as NSObject,
        ])
    }

    static func fetch() async {
        try? await shared.fetchAndActivate()
    }
}
```

### Reading Flags

```swift
// Bool flag
let isNotificationsEnabled = RemoteConfig.remoteConfig()
    .configValue(forKey: "enable_notifications").boolValue

// Number flag
let maxImages = RemoteConfig.remoteConfig()
    .configValue(forKey: "max_image_attachments").numberValue.intValue
```

### Usage in Views

```swift
struct HomeScreen: View {
    private var isNotificationsEnabled: Bool {
        RemoteConfig.remoteConfig()
            .configValue(forKey: "enable_notifications").boolValue
    }

    var body: some View {
        HomeNavBarView(
            onMenuTap: onMenuTap,
            onNotificationTap: isNotificationsEnabled ? onNotificationTap : nil,
            onProfileTap: onProfileTap
        )
    }
}
```

### Usage in ViewModels

ViewModel에서는 직접 Remote Config를 참조하지 않음. 대신 init 파라미터로 전달.

```swift
// GOOD — 의존성 주입
@Observable
final class HomeViewModelImpl: HomeViewModel {
    let isNotificationsEnabled: Bool

    init(isNotificationsEnabled: Bool, ...) {
        self.isNotificationsEnabled = isNotificationsEnabled
    }
}

// DIContainer에서 주입
container.register(HomeViewModel.self) { r in
    HomeViewModelImpl(
        isNotificationsEnabled: RemoteConfig.remoteConfig()
            .configValue(forKey: "enable_notifications").boolValue,
        ...
    )
}
```

## Feature Flag Registry

모든 플래그를 중앙 관리. 하드코딩된 문자열 키 방지.

```swift
// CoreBL/Utils/Configurations/FeatureFlag.swift
enum FeatureFlag: String {
    case enableNotifications = "enable_notifications"
    case enableSearchV2 = "enable_search_v2"
    case enableBookmark = "enable_bookmark"
    case maxImageAttachments = "max_image_attachments"

    var boolValue: Bool {
        RemoteConfig.remoteConfig().configValue(forKey: rawValue).boolValue
    }

    var intValue: Int {
        RemoteConfig.remoteConfig().configValue(forKey: rawValue).numberValue.intValue
    }
}

// Usage
if FeatureFlag.enableNotifications.boolValue {
    // show notifications
}
```

## Current Feature Status

현재 프로젝트의 미완성/부분 구현 기능:

| Feature | Status | Recommended Toggle |
|---|---|---|
| 알림 (Notifications) | UI 있음, 백엔드 없음 | `#if DEBUG` 또는 Remote Config |
| 검색 (Search) | 부분 구현 | Remote Config |
| 북마크 | 미구현 | `#if DEBUG` |
| 이미지 업로드 | UI 있음, Storage 미연결 | Remote Config |

## Progressive Rollout

### 단계별 롤아웃

```
1. 내부 테스트 (DEBUG)     → #if DEBUG
2. TestFlight 베타          → Remote Config: 100% beta
3. 프로덕션 5%             → Remote Config: 5% rollout
4. 프로덕션 25%            → Remote Config: 25% rollout
5. 프로덕션 100%           → Remote Config: 100%
6. 플래그 제거 (코드 정리)  → #if 제거, 코드만 유지
```

### Remote Config 조건

Firebase Console에서 조건 설정:
- **앱 버전**: `app.version >= 1.2.0`
- **사용자 %**: 랜덤 퍼센트
- **플랫폼**: iOS only
- **국가**: 한국만

## Lifecycle

```
1. FLAG 생성
   - FeatureFlag enum에 케이스 추가
   - Remote Config에 기본값 false 설정
   - 코드에서 분기 처리

2. FLAG 활성화
   - Firebase Console에서 true로 변경
   - 점진적 롤아웃 (5% → 25% → 100%)

3. FLAG 제거 (안정화 후)
   - 분기 코드 제거, 활성 경로만 유지
   - FeatureFlag enum에서 케이스 제거
   - Remote Config에서 키 제거
```

> 플래그는 영구적이 아님. 기능이 안정되면 반드시 제거.

## Rules

**DO:**
- 미완성 기능은 반드시 토글로 숨기기
- FeatureFlag enum으로 중앙 관리
- 기능 안정화 후 플래그 코드 제거
- ViewModel에는 init 파라미터로 플래그 전달
- 기본값은 항상 `false` (안전한 비활성)

**DON'T:**
- 하드코딩된 문자열 키 ("enable_xxx") 직접 사용
- ViewModel/UseCase에서 RemoteConfig 직접 import
- 플래그를 영구적으로 유지 (기술 부채)
- 플래그 없이 미완성 기능 main에 merge
- Release에서 DEBUG 전용 기능 노출
