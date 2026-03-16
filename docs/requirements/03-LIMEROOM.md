# 03. 라임룸 (LimeRoom)

## 개요

성격 유형별 커뮤니티 게시판. 15개 성격 유형(SDD, SDR, SDE, CDD, CDR, CDE, RDD, RDR, RDE, HDD, HDR, HDE, NDD, NDR, NDE)마다 독립된 게시판이 존재한다.

**화면**: `LimeRoomScreen`
**Route**: `.limeRoom(boardName: String)`
**ViewModel**: `LimeRoomViewModel`

---

## F-ROOM-01: 게시판 메타 정보

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| ROOM-01-01 | 상단에 게시판 이름 표시 (유형 코드 또는 한글명) | P0 | 구현됨 |
| ROOM-01-02 | 뒤로가기 버튼 → dismiss | P0 | 구현됨 |
| ROOM-01-03 | 게시판 탭 목록이 있으면 TabSelectorView로 탭 표시 | P1 | 구현됨 |

### 데이터 흐름

```
LimeRoomViewModel.loadMeta(boardName:)
  → UCGetLimeRoomMeta.getLimeRoomMeta(boardName:)
  → BoardRepository.getBoardInfoData(name:)
  → Firestore: BoardInfo/{boardName}
```

### 데이터 모델

```swift
struct LimeRoomMeta {
    let limeRoomName: String
    let limeRoomDescription: String
    let limeRoomTabs: [String]
    let limeRoomHotKeys: [String]
    let limeRoomRanking: [String]
}
```

---

## F-ROOM-02: 게시글 목록

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| ROOM-02-01 | 게시글 목록을 최근순으로 표시 | P0 | 구현됨 |
| ROOM-02-02 | 각 게시글에 제목, 작성자, 작성일, 조회수, 추천수, 댓글수 표시 | P0 | 구현됨 |
| ROOM-02-03 | 게시글 탭 시 상세 화면으로 이동 (`.boardPost(boardName:, postId:)`) | P0 | 구현됨 |
| ROOM-02-04 | 게시글 없을 경우 "게시글이 없습니다" 빈 상태 표시 | P0 | 구현됨 |
| ROOM-02-05 | 로딩 중 ProgressView 표시 | P1 | 구현됨 |
| ROOM-02-06 | 에러 발생 시 에러 배너 표시 | P1 | 구현됨 |

### 데이터 흐름

```
LimeRoomViewModel.loadPostList(boardName:, page:)
  → UCGetLimeRoomPostList.getLimeRoomPostList(boardName:, tabName:, counts:)
  → BoardRepository.getBoardPostMetaList(boardName:, startTime: "NaN", counts:)
  → Firestore: BoardInfo/{boardName}/Posts (PublishedTime desc, limit)
```

---

## F-ROOM-03: 페이지네이션

**컴포넌트**: `LimeRoomBottomBar`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| ROOM-03-01 | 하단 바에 페이지 번호 표시 (1~5) | P1 | 구현됨 |
| ROOM-03-02 | 페이지 번호 탭 시 해당 페이지 게시글 로드 | P1 | 구현됨 |
| ROOM-03-03 | 현재 페이지 하이라이트 | P1 | 구현됨 |
| ROOM-03-04 | 페이지당 10개 게시글 (counts = 10 * (page + 1)) | P1 | 구현됨 |

---

## F-ROOM-04: 글쓰기 버튼

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| ROOM-04-01 | 우하단에 플로팅 글쓰기 버튼 (연필 아이콘) | P0 | 구현됨 |
| ROOM-04-02 | 로그인 상태: 탭 시 글쓰기 화면으로 이동 (`.boardPostWrite(boardName:)`) | P0 | 구현됨 |
| ROOM-04-03 | 비로그인 상태: 탭 시 "로그인 필요" 알림 표시 | P0 | 구현됨 |
| ROOM-04-04 | 알림에서 "로그인" 선택 시 로그인 화면 이동 | P0 | 구현됨 |

---

## F-ROOM-05: 게시글 셀

**컴포넌트**: `PostCellView`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| ROOM-05-01 | 게시글 제목 표시 (1줄, 말줄임) | P0 | 구현됨 |
| ROOM-05-02 | 작성자명 표시 | P0 | 구현됨 |
| ROOM-05-03 | 작성 시간 표시 | P1 | 구현됨 |
| ROOM-05-04 | 추천수 (arrow.up 아이콘), 댓글수 (bubble 아이콘), 조회수 (eye 아이콘) 표시 | P0 | 구현됨 |
| ROOM-05-05 | NavigationLink로 게시글 상세 화면 연결 | P0 | 구현됨 |

---

## LimeRoomViewModel 인터페이스

```swift
protocol LimeRoomViewModel {
    var meta: LimeRoomMeta? { get }
    var postList: LimeRoomPostList? { get }
    var isLoggedIn: Bool { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    func loadMeta(boardName: String) async
    func loadPostList(boardName: String, page: Int) async
    func loadIsLoggedIn() async
}
```

---

## 화면 로딩 순서

```
1. LimeRoomViewModel 생성 (DI container resolve)
2. loadMeta(boardName:)     → 게시판 정보
3. loadPostList(boardName:, page: 0) → 첫 페이지 게시글
4. loadIsLoggedIn()         → 글쓰기 버튼 상태 결정
```

---

## 성격 유형 코드 (15종)

| 코드 | 한글명 |
|---|---|
| SDD | 활력성 우세 결핍형 |
| SDR | 활력성 우세 표준형 |
| SDE | 활력성 우세 과잉형 |
| CDD | 결집성 우세 결핍형 |
| CDR | 결집성 우세 표준형 |
| CDE | 결집성 우세 과잉형 |
| RDD | 수용성 우세 결핍형 |
| RDR | 수용성 우세 표준형 |
| RDE | 수용성 우세 과잉형 |
| HDD | 조화성 우세 결핍형 |
| HDR | 조화성 우세 표준형 |
| HDE | 조화성 우세 과잉형 |
| NDD | 무결정 결핍형 |
| NDR | 무결정 표준형 |
| NDE | 무결정 과잉형 |
