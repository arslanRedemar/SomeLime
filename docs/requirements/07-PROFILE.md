# 07. 프로필 (Profile)

## 개요

사용자 프로필 조회, 내 게시글/댓글 관리, 프로필 설정(닉네임 변경, 계정 삭제) 기능을 제공한다.

---

## F-PROF-01: 프로필 패널

**화면**: `ProfilePanel` (ZStack 오버레이, 우측 슬라이드)
**ViewModel**: `ProfileViewModel`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| PROF-01-01 | 로그인 상태: 프로필 아바타, 닉네임 표시 | P0 | 구현됨 |
| PROF-01-02 | 로그인 상태: 통계 표시 (게시글수, 추천수, 포인트, 활동일수) | P0 | 구현됨 |
| PROF-01-03 | 로그인 상태: 성격 테스트 결과 요약 (4축 캡슐, 유형 코드) | P1 | 구현됨 |
| PROF-01-04 | 로그인 상태: 메뉴 — 내 게시글, 내 댓글, 성격 테스트 결과, 프로필 설정 | P0 | 구현됨 |
| PROF-01-05 | 로그인 상태: "로그아웃" 버튼 → 로그아웃 실행 | P0 | 구현됨 |
| PROF-01-06 | 비로그인 상태: "로그인이 필요합니다" 안내 + 로그인 버튼 | P0 | 구현됨 |
| PROF-01-07 | 에러 발생 시 에러 배너 표시 | P1 | 구현됨 |
| PROF-01-08 | 패널 열릴 때마다 로그인 상태 재확인 및 프로필 데이터 새로고침 | P0 | 구현됨 |

### 네비게이션 (프로필 메뉴)

| 메뉴 | Route |
|---|---|
| 내 게시글 | `.userCurrentPosts` |
| 내 댓글 | `.userCurrentComments` |
| 성격 테스트 결과 | `.personalityTestResult` |
| 프로필 설정 | `.profileSettings` |
| 로그인 | `.login` |

### 데이터 흐름

```
ProfileViewModel.loadProfile()
  → UserRepository.getUserData()
  → DataSource.getUserData()  // Firestore: Users/{uid}

ProfileViewModel.loadTestResult()
  → PersonalityTestRepository.getPersonalityTestResult()
  → DataSource.getUserData()  // PersonalityTestResult, PersonalityType 파싱
```

### 데이터 모델

```swift
struct UserProfile {
    let userName: String
    let userID: String
    let userSignedDate: String
    let userPoints: Int
    let numOfPosts: Int
    let numOfReceivedVotes: Int
    let numOfComments: Int
    let numOfActiveDays: Int
}
```

---

## F-PROF-02: 내 게시글

**화면**: `UserCurrentPostsScreen`
**Route**: `.userCurrentPosts`
**ViewModel**: `UserCurrentPostsViewModel`

### 전제조건

- 로그인 필수

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| PROF-02-01 | 로그인 사용자가 작성한 모든 게시글 목록 표시 | P0 | 구현됨 |
| PROF-02-02 | 각 게시글에 제목, 게시판명, 작성일, 추천수, 댓글수, 조회수 표시 | P0 | 구현됨 |
| PROF-02-03 | 게시글 탭 시 상세 화면 이동 (`.boardPost(boardName:, postId:)`) | P0 | 구현됨 |
| PROF-02-04 | 게시글 없을 경우 빈 상태 표시 | P0 | 구현됨 |
| PROF-02-05 | 로딩 중 ProgressView 표시 | P1 | 구현됨 |
| PROF-02-06 | 에러 시 에러 메시지 표시 | P1 | 구현됨 |

### 데이터 흐름

```
UserCurrentPostsViewModel.loadPosts()
  → UserRepository.getUserPosts(userId:)
  → DataSource.getUserPosts(userId:)
  → 전체 성격 유형 게시판 순회, UserId == currentUid 필터링
```

**참고**: 모든 15개 유형 게시판(`SomeLiMePTTypeDesc.typeDetail.keys`)을 순회하여 해당 사용자의 게시글을 수집한다.

---

## F-PROF-03: 내 댓글

**화면**: `UserCurrentCommentsScreen`
**Route**: `.userCurrentComments`
**ViewModel**: `UserCurrentCommentsViewModel`

### 전제조건

- 로그인 필수

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| PROF-03-01 | 로그인 사용자가 작성한 모든 댓글 목록 표시 | P0 | 구현됨 |
| PROF-03-02 | 각 댓글에 내용, 작성자, 작성일 표시 | P0 | 구현됨 |
| PROF-03-03 | 댓글 탭 시 해당 게시글 상세 화면 이동 | P0 | 구현됨 |
| PROF-03-04 | 댓글 없을 경우 빈 상태 표시 | P0 | 구현됨 |
| PROF-03-05 | 로딩 중 ProgressView 표시 | P1 | 구현됨 |
| PROF-03-06 | 에러 시 에러 메시지 표시 | P1 | 구현됨 |

### 데이터 흐름

```
UserCurrentCommentsViewModel.loadComments()
  → UserRepository.getUserComments(userId:)
  → DataSource.getUserComments(userId:)
  → 전체 성격 유형 게시판 순회 → 각 게시글의 CommentList 순회
```

---

## F-PROF-04: 프로필 설정

**화면**: `ProfileSettingsScreen`
**Route**: `.profileSettings`
**ViewModel**: `ProfileSettingsViewModel`

### 전제조건

- 로그인 필수

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| PROF-04-01 | 현재 닉네임 표시 및 수정 입력 필드 | P0 | 구현됨 |
| PROF-04-02 | "닉네임 변경" 버튼 → Firestore `Users/{uid}.UserName` 업데이트 | P0 | 구현됨 |
| PROF-04-03 | 이메일 표시 (읽기 전용) | P1 | 구현됨 |
| PROF-04-04 | "비밀번호 변경" 버튼 → `.changePassword` 이동 | P1 | 구현됨 |
| PROF-04-05 | "계정 삭제" 버튼 → 확인 다이얼로그 후 계정 + 문서 삭제 | P0 | 구현됨 |
| PROF-04-06 | 닉네임 변경 성공/실패 메시지 표시 | P1 | 구현됨 |
| PROF-04-07 | 계정 삭제 시 Firebase Auth 계정 + Firestore 문서 삭제 | P0 | 구현됨 |

### 데이터 흐름

```
// 닉네임 변경
ProfileSettingsViewModel.updateNickname()
  → UserRepository.updateNickname(nickname:)
  → DataSource.updateUser(userInfo: ["UserName": nickname])

// 계정 삭제
ProfileSettingsViewModel.deleteAccount()
  → UserRepository.deleteUserData()      // Firestore Users/{uid} 삭제
  → AuthRepository.deleteAccount()       // Firebase Auth 계정 삭제
```

---

## ProfileViewModel 인터페이스

```swift
protocol ProfileViewModel {
    var userProfile: UserProfile? { get }
    var testResult: LimeTestResult? { get }
    var testReport: LimeTestReport? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    func loadProfile() async
    func loadTestResult() async
    func loadTestReport() async
    func signOut()
}
```

---

## Firestore Users 문서 구조

```
Users/{uid}
  ├── UserName: String
  ├── SignUpDate: String
  ├── Points: Int
  ├── NumOfPosts: Int
  ├── ReceivedUps: Int
  ├── DaysOfActive: Int
  ├── PersonalityTestResult: [Int, Int, Int, Int]  // [S, R, H, C]
  └── PersonalityType: String                       // 유형 코드
```
