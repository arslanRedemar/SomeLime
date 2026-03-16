# 04. 게시글 (Post)

## 개요

라임룸 내 게시글의 조회, 작성, 추천, 댓글, 신고 기능을 제공한다.

---

## F-POST-01: 게시글 상세 조회

**화면**: `BoardPostScreen`
**Route**: `.boardPost(boardName: String, postId: String)`
**ViewModel**: `BoardPostViewModel`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| POST-01-01 | 게시글 제목 표시 | P0 | 구현됨 |
| POST-01-02 | 작성자명, 작성일, 조회수 표시 | P0 | 구현됨 |
| POST-01-03 | 게시글 본문(Paragraph) 텍스트 표시 | P0 | 구현됨 |
| POST-01-04 | 게시글 이미지 표시 (URLs 배열) | P1 | 구현됨 |
| POST-01-05 | 추천수, 댓글수 표시 | P0 | 구현됨 |
| POST-01-06 | 로딩 중 ProgressView 표시 | P1 | 구현됨 |
| POST-01-07 | 뒤로가기 버튼 → dismiss | P0 | 구현됨 |

### Firestore 구조

```
BoardInfo/{boardName}/Posts/{postId}
  ├── PostTitle, UserId, UserName, PublishedTime, Views, VoteUps, CommentsNumber
  ├── BoardPostContents/Paragraph  → { Text: String }
  ├── BoardPostContents/Image      → { URLs: [String] }
  ├── BoardPostContents/Video      → { URLs: [String] }
  └── BoardPostContents/Comments/CommentList/{commentId}
```

### 데이터 흐름

```
BoardPostViewModel.loadPost(boardName:, postId:)
  → UCGetPost.getPostMeta(boardName:, postId:)
    → PostRepository.getBoardPostMeta(boardName:, postId:)
  → UCGetPost.getPostContent(boardName:, postId:)
    → PostRepository.getBoardPostContent(boardName:, postId:)
```

---

## F-POST-02: 게시글 추천 (좋아요)

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| POST-02-01 | 추천 버튼 (arrow.up 아이콘) 제공 | P0 | 구현됨 |
| POST-02-02 | 탭 시 Firestore 트랜잭션으로 `VoteUps` +1 (원자적 업데이트) | P0 | 구현됨 |
| POST-02-03 | 추천 후 버튼 비활성화 (중복 추천 방지) | P0 | 구현됨 |
| POST-02-04 | 추천 후 UI 즉시 반영 (낙관적 업데이트) | P1 | 구현됨 |

### Firestore 규칙

```
// Posts에 대해 authenticated 사용자 update 허용
allow update: if request.auth != null;
```

### 데이터 흐름

```
BoardPostViewModel.voteUp(boardName:, postId:)
  → UCRecommendPost.recommendPost(boardName:, postId:)
  → PostRepository.voteUpPost(boardName:, postId:)
  → FirebaseDataSource.voteUpPost()  // Firestore transaction
```

---

## F-POST-03: 게시글 작성

**화면**: `BoardPostWriteScreen`
**Route**: `.boardPostWrite(boardName: String)`
**ViewModel**: `BoardPostWriteViewModel`

### 전제조건

- 로그인 필수

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| POST-03-01 | 게시글 제목 입력 필드 (필수) | P0 | 구현됨 |
| POST-03-02 | 게시글 본문 입력 필드 (TextEditor) | P0 | 구현됨 |
| POST-03-03 | 이미지 첨부 버튼 (PhotosPicker, 최대 5장) | P1 | 구현됨 |
| POST-03-04 | 첨부된 이미지 썸네일 미리보기 | P1 | 구현됨 |
| POST-03-05 | 이미지 개별 삭제 (X 버튼) | P1 | 구현됨 |
| POST-03-06 | "등록" 버튼 → 게시글 Firestore 저장 | P0 | 구현됨 |
| POST-03-07 | 제목 미입력 시 "제목을 입력해주세요" 에러 | P0 | 구현됨 |
| POST-03-08 | 이미지 첨부 시 Firebase Storage 업로드 후 URL 저장 | P1 | 구현됨 |
| POST-03-09 | 작성 완료 시 dismiss | P0 | 구현됨 |
| POST-03-10 | 작성 중 로딩 표시 및 버튼 비활성화 | P1 | 구현됨 |
| POST-03-11 | `PublishedTime`은 `FieldValue.serverTimestamp()` 사용 | P0 | 구현됨 |

### Firestore 저장 구조

```
BoardInfo/{boardName}/Posts/{autoId}
  ├── BoardTap: String
  ├── CommentsNumber: 0
  ├── PostTitle: String
  ├── PostType: "text" | "image"
  ├── PublishedTime: serverTimestamp()
  ├── ThumbnailURL: ""
  ├── UserId: String (현재 uid)
  ├── UserName: String
  ├── Views: 0
  ├── VoteUps: 0
  └── BoardPostContents/
        ├── Paragraph: { Text: String }
        ├── Image: { URLs: [String] }
        └── Video: { URLs: [] }
```

---

## F-POST-04: 댓글

**컴포넌트**: `CommentCellView`, `CommentInputView`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| POST-04-01 | 게시글 하단에 댓글 목록 표시 (작성순) | P0 | 구현됨 |
| POST-04-02 | 각 댓글에 작성자명, 내용, 작성일 표시 | P0 | 구현됨 |
| POST-04-03 | 하단 고정 댓글 입력 영역 제공 | P0 | 구현됨 |
| POST-04-04 | "등록" 버튼 → Firestore 댓글 저장 | P0 | 구현됨 |
| POST-04-05 | 댓글 작성 후 목록 즉시 갱신 | P0 | 구현됨 |
| POST-04-06 | 댓글 작성 중 로딩 표시 | P1 | 구현됨 |
| POST-04-07 | 빈 댓글 입력 방지 | P0 | 구현됨 |

### Firestore 저장 경로

```
BoardInfo/{boardName}/Posts/{postId}/BoardPostContents/Comments/CommentList/{autoId}
  ├── Text: String
  ├── Target: String
  ├── UserName: String
  ├── UserId: String
  ├── PostId: String
  ├── PublishedTime: String
  └── IsRevised: "No"
```

### 데이터 흐름

```
// 댓글 조회
BoardPostViewModel.loadComments(boardName:, postId:)
  → UCGetComments.getComments(boardName:, postId:)
  → PostRepository.getComments(boardName:, postId:)

// 댓글 작성
BoardPostViewModel.submitComment(boardName:, postId:, text:)
  → UCWriteComment.writeComment(boardName:, postId:, target:, text:)
  → PostRepository.writeComment(boardName:, postId:, target:, text:)
```

---

## F-POST-05: 게시글 신고

**화면**: `ReportScreen`
**Route**: `.report(boardName: String, postId: String)`
**ViewModel**: `ReportViewModel`

### 요구사항

| ID | 설명 | 우선순위 | 상태 |
|---|---|---|---|
| POST-05-01 | 신고 사유 라디오 버튼 목록 제공 | P0 | 구현됨 |
| POST-05-02 | 상세 설명 입력 필드 (TextEditor) | P1 | 구현됨 |
| POST-05-03 | "신고" 버튼 → Firestore `Reports` 컬렉션에 저장 | P0 | 구현됨 |
| POST-05-04 | 신고 완료 시 dismiss | P0 | 구현됨 |
| POST-05-05 | 사유 미선택 시 에러 표시 | P0 | 구현됨 |
| POST-05-06 | 에러 발생 시 에러 메시지 표시 | P1 | 구현됨 |

### Firestore 저장 구조

```
Reports/{autoId}
  ├── BoardName: String
  ├── PostId: String
  ├── Reason: String
  ├── Detail: String
  ├── ReporterId: String (현재 uid)
  ├── ReportedTime: String
  └── Status: "pending"
```

### Firestore 규칙

```
match /Reports/{reportId} {
  allow create: if request.auth != null;
  allow read, update, delete: if false;
}
```

---

## BoardPostViewModel 인터페이스

```swift
protocol BoardPostViewModel {
    var meta: LimeRoomPostMeta? { get }
    var content: LimeRoomPostContent? { get }
    var comments: [LimeRoomPostComment] { get }
    var isLoading: Bool { get }
    var isSubmittingComment: Bool { get }
    var hasVoted: Bool { get }
    func loadPost(boardName: String, postId: String) async
    func loadComments(boardName: String, postId: String) async
    func submitComment(boardName: String, postId: String, text: String) async
    func voteUp(boardName: String, postId: String) async
}
```

---

## 데이터 모델

```swift
struct LimeRoomPostMeta {
    let userID, userName, title: String
    let views: Int
    let publishedTime: String
    let numOfVotes, numOfComments, numOfViews: Int
    let postID, boardPostTap, boardName: String
}

struct LimeRoomPostContent {
    let paragraph: String
    let imageURLs: [String]
    let videoURLs: [String]
}

struct LimeRoomPostComment {
    let userName, userId, text, publishedTime, target, postId: String
}
```
