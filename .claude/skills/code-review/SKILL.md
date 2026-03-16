---
name: code-review
description: Code review checklist and architectural compliance rules for the Somlimee project. Verifies Clean Architecture boundaries, import rules, DI patterns, design system compliance, and accessibility. Use when reviewing PRs, auditing code, or before merging.
---

# Code Review

Somlimee 프로젝트 코드 리뷰 체크리스트. Clean Architecture 준수, 디자인 시스템 적용, 접근성 확인.

## Review Checklist

PR 리뷰 시 아래 항목을 순서대로 확인.

### 1. Architecture Compliance

```
[ ] Entity/Model/Repository/UseCase/ViewModel에 UIKit 또는 Firebase import 없음
[ ] ViewModel이 DataSource를 직접 참조하지 않음 (UseCase/Repository 경유)
[ ] 새 서비스가 DIContainer.setupContainer()에 등록됨
[ ] 의존성 방향: View → ViewModel → UseCase → Repository → DataSource
[ ] 프로토콜 + Impl 패턴 준수 (예: UserRepository + UserRepositoryImpl)
```

### 2. Import Rules

| Layer | 허용 | 금지 |
|---|---|---|
| Entities/ | `Foundation` | UIKit, SwiftUI, Firebase, SQLite |
| Models/ | `Foundation` | UIKit, SwiftUI, Firebase, SQLite |
| Repositories/ | `Foundation` | UIKit, SwiftUI, Firebase, SQLite |
| UseCases/ | `Foundation` | UIKit, SwiftUI, Firebase, SQLite |
| ViewModels/ | `Foundation` | UIKit, SwiftUI, Firebase, SQLite |
| Data/ | `Foundation`, `Firebase`, `SQLite`, `UIKit` | SwiftUI |
| SwiftUIViews/ | `SwiftUI`, `Swinject` | UIKit, Firebase, SQLite |
| CoreBL/Utils/Configurations/ | `SwiftUI`, `UIKit` (Colors/Fonts only) | Firebase |

**검증 방법:**
```bash
# Entity/ViewModel에서 UIKit import 검색
grep -rn "import UIKit\|import Firebase\|import SQLite" \
  Somlimee/Entities/ Somlimee/ViewModels/ Somlimee/UseCases/ Somlimee/Repositories/
```

### 3. DI & Injection

```
[ ] 모든 의존성이 생성자 주입 (init parameter)
[ ] 싱글톤 패턴 없음 (sharedInstance, static let shared)
[ ] DataSource는 .inObjectScope(.container) (공유 인스턴스)
[ ] ViewModel/UseCase/Repository는 transient (기본값)
[ ] @Environment(\.diContainer)로 컨테이너 접근
```

### 4. Design System (designing-ui)

```
[ ] somLime* 컬러 토큰 사용 (raw Color.blue, .red 없음)
[ ] SpoqaHanSansNeo 폰트 사용 (.body, .headline, .caption 없음)
[ ] 아이콘 전용 버튼에 .accessibilityLabel() 있음
[ ] 44x44pt 최소 탭 타겟
[ ] .foregroundStyle 사용 (.foregroundColor 아님)
[ ] 한국어 사용자 문자열
```

### 5. Data Layer Boundary

```
[ ] Firebase Timestamp → String 변환이 FirebaseDataSource 경계에서 수행
[ ] DataSource 위 레이어에서 Firebase 타입 미사용
[ ] SQLiteDatabaseCommands에 database: Connection? 파라미터 전달
[ ] convertTimestamps() 호출하여 Timestamp 변환
```

### 6. Navigation

```
[ ] 새 화면에 Route enum 케이스 추가
[ ] RootView.swift의 .navigationDestination에 등록
[ ] .navigationBarHidden(true) 설정
[ ] 커스텀 nav bar 구현 (시스템 nav bar 미사용)
```

### 7. Error Handling

```
[ ] try? 대신 do/catch 사용 (에러 삼킴 방지)
[ ] ViewModel에 errorMessage 설정
[ ] 사용자에게 에러 표시 (한국어)
[ ] Failure 타입 사용 (적절한 경우)
```

### 8. Requirements

```
[ ] 요구사항 문서(docs/requirements/) 업데이트됨
[ ] 새 기능에 요구사항 ID 부여 (예: HOME-04-06)
[ ] 상태값 업데이트 (planned → implemented)
```

### 9. Testing

```
[ ] 새 ViewModel에 테스트 있음
[ ] 새 UseCase에 테스트 있음
[ ] 기존 테스트 통과
```

## Severity Levels

| Level | 의미 | 예시 |
|---|---|---|
| **Blocker** | merge 불가 | Import 규칙 위반, 아키텍처 위반, 빌드 실패 |
| **Major** | 수정 후 merge | 에러 핸들링 누락, accessibilityLabel 없음 |
| **Minor** | 다음 PR에서 수정 가능 | 코드 스타일, 네이밍 개선 |
| **Nit** | 선택적 | 주석, 순서 변경 |

## Common Violations

### Architecture

```swift
// BAD: ViewModel이 DataSource 직접 접근
class MyViewModel {
    let dataSource: DataSource  // 위반!
}

// GOOD: Repository/UseCase 경유
class MyViewModel {
    let userRepo: UserRepository
}
```

### Import

```swift
// BAD: ViewModel에서 Firebase import
import Firebase  // 위반!

// GOOD: Foundation만
import Foundation
```

### Design System

```swift
// BAD: 시스템 폰트
.font(.headline)  // 위반!

// GOOD: 프로젝트 폰트
.font(.hanSansNeoBold(size: 16, relativeTo: .headline))

// BAD: raw 컬러
.foregroundStyle(.blue)  // 위반!

// GOOD: 프로젝트 토큰
.foregroundStyle(Color.somLimePrimary)
```

### DI

```swift
// BAD: 싱글톤
static let shared = MyService()  // 위반!

// GOOD: 생성자 주입
init(service: MyService) { self.service = service }
```

## Automated Checks

빌드 시 자동 확인 가능한 항목:

```bash
# 아키텍처 위반 검사
grep -rn "import UIKit" Somlimee/Entities/ Somlimee/ViewModels/ && echo "FAIL" || echo "PASS"
grep -rn "import Firebase" Somlimee/ViewModels/ Somlimee/UseCases/ && echo "FAIL" || echo "PASS"

# 싱글톤 검사
grep -rn "sharedInstance\|static let shared\|static var shared" Somlimee/ && echo "FAIL" || echo "PASS"

# 시스템 폰트 검사
grep -rn '\.font(\.\(body\|headline\|title\|caption\|subheadline\))' Somlimee/SwiftUIViews/ && echo "FAIL" || echo "PASS"

# accessibilityLabel 없는 아이콘 버튼 (수동 확인 필요)
```

## Review Comment Templates

```
# Blocker
🚫 [Architecture] ViewModel에서 Firebase를 직접 import하고 있습니다.
Repository/UseCase를 통해 접근해주세요.

# Major
⚠️ [A11y] 이 아이콘 버튼에 .accessibilityLabel()이 없습니다.
VoiceOver 사용자가 버튼 기능을 알 수 없습니다.

# Minor
💡 [Style] .foregroundColor 대신 .foregroundStyle을 사용해주세요.

# Nit
📝 [Nit] 이 메서드명은 loadData보다 loadUserProfile이 더 명확합니다.
```
