# 06. 검색 (Search)

## 개요

전체 게시판 대상 텍스트 검색 기능. 제목/내용/제목+내용 범위를 선택할 수 있으며, 홈 트렌드 키워드 탭으로도 검색 결과를 볼 수 있다.

---

## F-SEARCH-01: 전체 검색

**화면**: `SearchScreen`
**Route**: `.search`
**ViewModel**: `SearchViewModel`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| SEARCH-01-01 | 검색어 입력 필드 제공 | P0 | 구현됨 |
| SEARCH-01-02 | 검색 범위 선택: 제목 / 내용 / 제목+내용 (SearchScope) | P1 | 구현됨 |
| SEARCH-01-03 | 게시판 필터 선택 (선택적, availableBoards 목록) | P2 | 구현됨 |
| SEARCH-01-04 | 검색 실행 시 전체 게시판에서 일치하는 게시글 조회 | P0 | 구현됨 |
| SEARCH-01-05 | 결과를 게시판별로 그룹화하여 표시 | P0 | 구현됨 |
| SEARCH-01-06 | 검색 결과 게시글 탭 시 상세 화면 이동 (`.boardPost`) | P0 | 구현됨 |
| SEARCH-01-07 | 빈 검색어 시 검색 미실행 | P0 | 구현됨 |
| SEARCH-01-08 | 검색 결과 없을 경우 빈 상태 표시 | P0 | 구현됨 |
| SEARCH-01-09 | 로딩 중 ProgressView 표시 | P1 | 구현됨 |
| SEARCH-01-10 | 에러 시 "검색에 실패했습니다" 메시지 표시 | P1 | 구현됨 |
| SEARCH-01-11 | 화면 진입 시 게시판 목록 로드 (`loadBoards()`) | P1 | 구현됨 |

### 검색 범위 (SearchScope)

```swift
enum SearchScope {
    case title
    case content
    case titleAndContent
}
```

### 검색 로직

```
1. 검색어 trim
2. boardName이 지정되면 해당 게시판만, 아니면 전체 게시판 대상
3. 각 게시판의 최근 50개 게시글 메타 로드
4. scope에 따라 제목/내용에 lowercased 포함 여부 확인
5. 일치하는 게시글을 SearchResultItem으로 매핑
6. 게시판별로 그룹화
```

### 데이터 흐름

```
SearchViewModel.search()
  → UCSearch.execute(query:, boardName:, scope:)
  → SearchRepository.searchPosts(query:, boardName:, scope:, counts: 50)
  → DataSource.getBoardPostMetaList(boardName:, startTime: "NaN", counts:)
  → 클라이언트 측 필터링

SearchViewModel.loadBoards()
  → UCSearch.getAvailableBoards()
  → SearchRepository.getAvailableBoards()
  → DataSource.getBoardListData()
```

### 데이터 모델

```swift
struct SearchResult {
    let query: String
    let items: [SearchResultItem]
    let groupedByBoard: [String: [SearchResultItem]]
}

struct SearchResultItem {
    let postMeta: LimeRoomPostMeta
    let boardDisplayName: String
}
```

---

## F-SEARCH-02: 트렌드 검색 결과

**화면**: `TrendSearchResultScreen`
**Route**: `.trendSearchResult(keyword: String)`
**ViewModel**: `SearchViewModel` (재사용)

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| SEARCH-02-01 | 트렌드 키워드를 검색어로 자동 설정하여 검색 실행 | P1 | 구현됨 |
| SEARCH-02-02 | 결과를 게시판별로 그룹화하여 표시 (게시판명 + 건수 배지) | P1 | 구현됨 |
| SEARCH-02-03 | 게시글 탭 시 상세 화면 이동 | P1 | 구현됨 |
| SEARCH-02-04 | 뒤로가기 버튼 | P0 | 구현됨 |

---

## SearchViewModel 인터페이스

```swift
protocol SearchViewModel {
    var searchText: String { get set }
    var scope: SearchScope { get set }
    var selectedBoard: String? { get set }
    var availableBoards: [String] { get }
    var results: [SearchResultItem] { get }
    var groupedResults: [String: [SearchResultItem]] { get }
    var isLoading: Bool { get }
    var hasSearched: Bool { get }
    var errorMessage: String? { get }
    func search() async
    func loadBoards() async
}
```

---

## UCSearch 인터페이스

```swift
protocol UCSearch {
    func execute(query: String, boardName: String?, scope: SearchScope) async -> Result<SearchResult, Error>
    func getAvailableBoards() async -> Result<[String], Error>
}
```
