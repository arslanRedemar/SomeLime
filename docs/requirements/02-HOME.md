# 02. 홈 화면 (Home)

## 개요

앱 메인 화면. 실시간 트렌드, MY라임방(성격 유형별 게시판), 오늘의 라임, 라임 테스트, 기타 라임방 목록을 탭 형태로 제공한다.

**화면**: `HomeScreen`
**Route**: 기본 화면 (NavigationStack root)
**ViewModel**: `HomeViewModel`

---

## F-HOME-01: 상단 네비게이션 바

**컴포넌트**: `HomeNavBarView`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| HOME-01-01 | 좌측 햄버거 메뉴 버튼 → 사이드 메뉴 열기 | P0 | 구현됨 |
| HOME-01-02 | 우측 알림 벨 아이콘 → 알림 화면 네비게이션 | P1 | 구현됨 |
| HOME-01-03 | 우측 프로필 아이콘 → 프로필 패널 열기 | P0 | 구현됨 |
| HOME-01-04 | 읽지 않은 알림이 있을 때만 알림 벨에 빨간 점 표시 (알림 확인 시 제거) | P2 | 구현됨 |
| HOME-01-05 | 앱 로고/타이틀 표시 | P1 | 구현됨 |

---

## F-HOME-02: 라임 트렌드

**컴포넌트**: `LimeTrendSection`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| HOME-02-01 | Firestore `RealTime/RTLimeTrends` 문서에서 트렌드 키워드 로드 | P0 | 구현됨 |
| HOME-02-02 | 가로 스크롤 캐러셀 형태로 트렌드 키워드 표시 | P0 | 구현됨 |
| HOME-02-03 | 키워드 탭 시 해당 키워드로 트렌드 검색 결과 화면 이동 (`.trendSearchResult`) | P1 | 구현됨 |
| HOME-02-04 | 트렌드 데이터 없을 경우 섹션 미표시 | P1 | 구현됨 |

### 데이터 흐름

```
HomeViewModel.loadTrends()
  → RealTimeRepository.getLimeTrendsData()
  → DataSource.getLimeTrendsData()
  → Firestore: RealTime/RTLimeTrends
```

### 데이터 모델

```swift
struct SomeLimeTrends {
    let list: [String]  // 트렌드 키워드 배열
}
```

---

## F-HOME-03: 탭 선택기

**컴포넌트**: `TabSelectorView`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| HOME-03-01 | 3개 탭 제공: "MY라임방", "오늘의 라임", "라임 테스트" | P0 | 구현됨 |
| HOME-03-02 | 선택된 탭은 primary 색상 언더라인으로 강조 | P0 | 구현됨 |
| HOME-03-03 | 탭 전환 시 하단 콘텐츠 영역 변경 | P0 | 구현됨 |

---

## F-HOME-04: MY라임방 (로그인 상태)

**컴포넌트**: `MyLimeRoomLoggedSection`

### 전제조건

- 사용자 로그인 상태
- `userStatus.isLoggedIn == true`
- 성격 테스트 완료 (`userTypeName` 비어있지 않음)

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| HOME-04-01 | 사용자의 성격 유형명 표시 (예: "SDR") | P0 | 구현됨 |
| HOME-04-02 | 해당 유형 게시판의 최근 게시글 5개 표시 | P0 | 구현됨 |
| HOME-04-03 | 게시글 탭 시 해당 게시글 상세 화면으로 이동 (`.boardPost`) | P0 | 구현됨 |
| HOME-04-04 | "더보기" 버튼 → 해당 라임룸으로 이동 (`.limeRoom`) | P1 | 구현됨 |
| HOME-04-05 | 성격 유형이 빈 문자열이면 (테스트 미완료) 게시글 로드 생략 | P0 | 구현됨 |
| HOME-04-06 | 로그인 상태이나 성격 테스트 미완료 시 테스트 유도 안내 표시 | P0 | 구현됨 |

### 데이터 흐름

```
HomeViewModel.loadMyLimeRoomPostsList(limeRoomName:)
  → BoardRepository.getBoardPostMetaList(boardName:, startTime: "NaN", counts: 5)
  → Firestore: BoardInfo/{typeName}/Posts (최근순 5개)
```

---

## F-HOME-05: MY라임방 (비로그인 상태)

**컴포넌트**: `MyLimeRoomNotLoggedSection`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| HOME-05-01 | "로그인하고 나만의 라임방을 만나보세요" 안내 문구 표시 | P0 | 구현됨 |
| HOME-05-02 | "로그인" 버튼 → `.login` 화면 네비게이션 | P0 | 구현됨 |
| HOME-05-03 | "회원가입" 버튼 → `.signUp` 화면 네비게이션 | P1 | 구현됨 |

---

## F-HOME-06: 오늘의 라임

**컴포넌트**: `LimesTodaySection`
**ViewModel**: `HomeLimesTodayViewModel`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| HOME-06-01 | 전체 게시판에서 오늘의 인기 게시글 로드 | P1 | 구현됨 |
| HOME-06-02 | 게시글 목록 표시 (제목, 작성자, 추천수, 댓글수) | P1 | 구현됨 |
| HOME-06-03 | 게시글 탭 시 상세 화면으로 이동 | P1 | 구현됨 |

### 데이터 흐름

```
HomeLimesTodayViewModel.loadPostList()
  → BoardRepository.getBoardPostMetaList(boardName:, startTime: "NaN", counts: 10)
```

---

## F-HOME-07: 라임 테스트

**컴포넌트**: `LimeTestSection`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| HOME-07-01 | 이용 가능한 성격 테스트 카드 목록 표시 | P1 | 구현됨 |
| HOME-07-02 | 테스트 카드에 유형 코드, 유형 설명 표시 | P1 | 구현됨 |
| HOME-07-03 | 카드 탭 시 성격 테스트 목록 화면 이동 (`.psyTestList`) | P1 | 구현됨 |

### 데이터 흐름

```
HomeViewModel.loadPsyTestList()
  → SomeLiMePTTypeDesc.typeDetail.keys.sorted()  // 15개 유형 코드
```

---

## F-HOME-08: 기타 라임방 목록

**컴포넌트**: `OtherLimeRoomsSection`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| HOME-08-01 | 모든 성격 유형 게시판 카드 가로 스크롤 표시 | P0 | 구현됨 |
| HOME-08-02 | 카드에 유형 코드 + 유형 설명 표시 | P0 | 구현됨 |
| HOME-08-03 | 카드 탭 시 해당 라임룸으로 이동 (`.limeRoom(boardName:)`) | P0 | 구현됨 |

### 데이터 흐름

```
HomeViewModel.loadLimeRoomList()
  → SomeLiMePTTypeDesc.typeDetail.keys.sorted()  // 15개 유형 코드
```

---

## HomeViewModel 인터페이스

```swift
protocol HomeViewModel {
    var trends: SomeLimeTrends? { get }
    var userTypeName: UserLimeTypeName? { get }
    var userStatus: UserStatus? { get }
    var myLimeRoomPostList: LimeRoomPostList? { get }
    var limeRoomList: LimeRoomList? { get }
    var psyTestList: PsyTestList? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    func loadTrends() async
    func loadUserTypeName() async
    func loadUserStatus() async
    func loadMyLimeRoomPostsList(limeRoomName: String) async
    func loadLimeRoomList() async
    func loadPsyTestList() async
    func refreshUserStatus() async
    func setUserStatusChangeListener(_ handler: @escaping (String?) -> Void)
}
```

---

## 화면 로딩 순서

```
1. HomeViewModel 생성 (DI container resolve)
2. loadTrends()       → 트렌드 섹션
3. loadUserStatus()   → 로그인 여부 결정
4. loadUserTypeName() → 성격 유형 확인
5. loadLimeRoomList() → 기타 라임방 목록
6. loadPsyTestList()  → 테스트 목록
7. if userTypeName != nil && !empty:
     loadMyLimeRoomPostsList(limeRoomName:) → MY라임방 게시글
```
