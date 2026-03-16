# SomeLiMe - 성격 유형 기반 커뮤니티 앱

**Somebody Like Me**의 줄임말. 심리테스트로 사용자의 성격 유형을 분석하고, 비슷한 가치관을 가진 사람들끼리 소통하는 iOS 커뮤니티 앱입니다.

## 기술 스택

- **iOS 17+** / SwiftUI
- **Firebase** (Auth, Firestore, Storage)
- **SQLite.swift** — 로컬 캐싱
- **Swinject** — 의존성 주입
- **아키텍처** — Clean Architecture (View → ViewModel → UseCase → Repository → DataSource)

## 프로젝트 구조

```
Somlimee/
├── SwiftUIViews/        # 22개 화면, 18개 컴포넌트
│   ├── Screens/
│   ├── Components/
│   └── Navigation/      # 20-case Route enum
├── ViewModels/          # 18개 (@Observable, 프로토콜+Impl)
├── UseCases/            # 12개 (UC 접두어)
├── Repositories/        # 12개 (프로토콜+Impl)
├── Data/                # FirebaseDataSource + SQLiteDataSource
├── Entities/            # 도메인 모델 (Foundation only)
└── CoreBL/              # 에러, 로깅, DI, 디자인 시스템
SomlimeeTests/           # 59개 테스트 파일
docs/requirements/       # 기능별 요구사항 문서
```

## 실행 방법

```bash
# CocoaPods 의존성 설치
pod install

# 반드시 .xcworkspace로 열기 (.xcodeproj 사용 금지)
open Somlimee.xcworkspace
```

빌드 및 실행은 Xcode에서 진행합니다.

---

## 현재 상태

### 완성된 기능 ✅

| 기능 | 설명 |
|------|------|
| 인증 | 로그인, 회원가입, 이메일 인증, 비밀번호 찾기/변경 |
| 홈 | 실시간 트렌드, MY라임방, 오늘의 라임, 라임 테스트 목록 |
| 라임룸 | 게시판 목록, 게시글 목록, 페이지네이션 |
| 게시글 | 게시글 조회/작성, 이미지 첨부 (5장), 추천, 신고 |
| 댓글 | 댓글 조회/작성, 즉시 갱신 |
| 성격 테스트 | 5점 척도 설문, 4축 점수 계산, 유형 결정 및 결과 저장 |
| 검색 | 전체 검색, 게시판 필터, 트렌드 검색 결과 |
| 프로필 | 프로필 패널, 내 게시글/댓글 목록, 닉네임 변경, 계정 삭제 |
| 네비게이션 | 타입 세이프 Route enum, 사이드 메뉴, 프로필 패널 슬라이드 |

### 미완성 / 부분 구현 ⚠️

| 기능 | 완성도 | 상태 |
|------|--------|------|
| 알림 | 40% | UI는 완성. 실제 알림 데이터 미연동 — `notifications = []` 하드코딩 상태 |
| 다크모드 | UI만 | 설정 토글은 동작하나 ColorScheme 적용 안 됨 — 시각적 변화 없음 |
| 댓글 알림 푸시 | 미구현 | FCM 미연동. 설정 토글만 존재 |
| 앱 버전 정보 | 부분 | `"1.0.0"` 하드코딩 |

---

## 보완해야 할 사항

### 🔴 기능 미완성

1. **알림 시스템** — `NotificationRepository.getNotifications()` 구현 및 Firestore 알림 컬렉션 설계 필요. 홈 화면 배지(unreadCount)도 항상 0
2. **FCM 푸시 알림** — 댓글/추천 이벤트 트리거 서버 측 Cloud Functions 미구현
3. **다크모드** — `AppSettingsViewModel`에서 `darkModeEnabled`를 저장하지만 RootView에서 `.preferredColorScheme()` 미적용

### 🟡 코드 품질

- **에러 메시지 혼용** — 대부분 한국어이나 일부 영문 메시지 잔존 (예: LoginScreen `"Login failed"`)
- **ViewModel 로딩 패턴 중복** — 여러 ViewModel에서 동일한 `isLoading / errorMessage` 처리 반복, 공통 기반 클래스 추출 고려
- **미사용 코드** — `CoreBL/Functions/userNameParser.swift` dead code

### 🟢 개선 사항 (낮은 우선순위)

- SwiftUI View 레이어 테스트 없음 (현재 ViewModel/UseCase/Repository 계층만 테스트)
- E2E 테스트 없음
- 성격 유형 상수(`SomeLiMePTTypeDesc`)가 앱 코드에 하드코딩 — 향후 Firestore Remote Config 이관 고려

---

## 테스트

```bash
# Xcode에서 테스트 실행
xcodebuild test -workspace Somlimee.xcworkspace -scheme Somlimee \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

- 총 **59개 테스트 파일** (ViewModel 24 / UseCase 12 / Repository 15 / 통합 4 / 기타 4)
- Firestore Emulator 기반 통합 테스트 포함
- Mock: `MockAuthRepository`, `MockDataSource`, `MockRepositories`, `MockUseCases`

## Firebase 인프라

- 상세 내용은 [FIREBASE_INFRASTRUCTURE.md](./FIREBASE_INFRASTRUCTURE.md) 참고
- Firestore 보안 규칙 배포: `firebase deploy --only firestore:rules`
