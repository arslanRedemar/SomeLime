---
name: qa-testing
description: Test strategy, patterns, and conventions for the Somlimee project. Covers unit tests for ViewModels, UseCases, and Repositories with Mock DataSource patterns, async/await testing, and coverage requirements. Use when writing tests, reviewing test coverage, or setting up test infrastructure.
---

# QA Testing

Somlimee 프로젝트 테스트 전략. Clean Architecture 레이어별 테스트 패턴과 Mock 전략.

## Test Structure

```
SomlimeeTests/
  Mocks/
    MockDataSource.swift         # DataSource 프로토콜 Mock
    MockAuthRepository.swift     # AuthRepository Mock
    MockRepositories.swift       # 기타 Repository Mock
  ViewModels/
    HomeViewModelTests.swift
    ProfileViewModelTests.swift
    ...
  UseCases/
    UCGetPostTests.swift
    UCWritePostTests.swift
    ...
  Repositories/
    UserRepositoryTests.swift
    BoardRepositoryTests.swift
    ...
  Data/
    FirebaseDataSourceTests.swift  # Integration (optional)
```

## Test Naming Convention

```swift
func test_[메서드명]_[시나리오]_[기대결과]()
```

Examples:
```swift
func test_loadProfile_whenLoggedIn_setsUserProfile()
func test_loadProfile_whenNotLoggedIn_clearsData()
func test_execute_withInvalidBoardName_returnsFailure()
func test_voteUp_whenAlreadyVoted_doesNotIncrement()
```

## Layer-Specific Patterns

### ViewModel Tests

ViewModel은 UseCase/Repository를 Mock하여 테스트.

```swift
import XCTest
@testable import Somlimee

final class ProfileViewModelTests: XCTestCase {
    private var sut: ProfileViewModelImpl!
    private var mockUserRepo: MockUserRepository!
    private var mockTestRepo: MockPersonalityTestRepository!
    private var mockAuthRepo: MockAuthRepository!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserRepository()
        mockTestRepo = MockPersonalityTestRepository()
        mockAuthRepo = MockAuthRepository()
        sut = ProfileViewModelImpl(
            userRepo: mockUserRepo,
            personalityTestRepo: mockTestRepo,
            authRepo: mockAuthRepo
        )
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_loadProfile_whenLoggedIn_setsUserProfile() async {
        // Given
        mockAuthRepo.isLoggedInResult = true
        mockUserRepo.getUserDataResult = ProfileData(
            userName: "TestUser",
            signUpDate: "2024-01-01",
            points: 100,
            numOfPosts: 5,
            receivedUps: 10,
            daysOfActive: 30
        )

        // When
        await sut.loadProfile()

        // Then
        XCTAssertTrue(sut.isLoggedIn)
        XCTAssertNotNil(sut.userProfile)
        XCTAssertEqual(sut.userProfile?.userName, "TestUser")
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadProfile_whenNotLoggedIn_clearsData() async {
        // Given
        mockAuthRepo.isLoggedInResult = false

        // When
        await sut.loadProfile()

        // Then
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertNil(sut.userProfile)
    }
}
```

### UseCase Tests

UseCase는 Repository를 Mock하여 테스트.

```swift
final class UCGetPostTests: XCTestCase {
    private var sut: UCGetPostImpl!
    private var mockPostRepo: MockPostRepository!
    private var mockBoardRepo: MockBoardRepository!

    override func setUp() {
        super.setUp()
        mockPostRepo = MockPostRepository()
        mockBoardRepo = MockBoardRepository()
        sut = UCGetPostImpl(
            postRepository: mockPostRepo,
            boardRepository: mockBoardRepo
        )
    }

    func test_execute_withValidPost_returnsContent() async {
        // Given
        mockPostRepo.getPostContentResult = .success(
            BoardPostContentData(paragraph: "Test", imageURLs: [])
        )

        // When
        let result = await sut.execute(boardName: "SDR", postId: "post_1")

        // Then
        switch result {
        case .success(let content):
            XCTAssertEqual(content.paragraph, "Test")
        case .failure:
            XCTFail("Expected success")
        }
    }
}
```

### Repository Tests

Repository는 DataSource를 Mock하여 테스트.

```swift
final class UserRepositoryTests: XCTestCase {
    private var sut: UserRepositoryImpl!
    private var mockDataSource: MockDataSource!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = UserRepositoryImpl(dataSource: mockDataSource)
    }

    func test_getUserData_returnsProfileData() async throws {
        // Given
        mockDataSource.getUserDataResult = [
            "UserName": "TestUser",
            "SignUpDate": "2024-01-01"
        ]

        // When
        let data = try await sut.getUserData()

        // Then
        XCTAssertEqual(data?.userName, "TestUser")
    }
}
```

## Mock Patterns

### Protocol-Based Mocking

모든 Mock은 기존 프로토콜을 구현. 외부 라이브러리 불필요.

```swift
final class MockAuthRepository: AuthRepository {
    var isLoggedInResult = false
    var currentUserIDResult: String? = "test_uid"
    var signInError: Error?
    var signOutError: Error?

    var isLoggedIn: Bool { isLoggedInResult }
    var currentUserID: String? { currentUserIDResult }

    func signIn(email: String, password: String) async throws {
        if let error = signInError { throw error }
    }

    func signOut() throws {
        if let error = signOutError { throw error }
    }

    // ... 나머지 메서드
}
```

### Call Tracking

호출 여부와 파라미터 확인이 필요할 때:

```swift
final class MockPostRepository: PostRepository {
    var getPostContentCalled = false
    var getPostContentArgs: (boardName: String, postId: String)?
    var getPostContentResult: Result<BoardPostContentData, Error> = .failure(NSError())

    func getPostContent(boardName: String, postId: String) async throws -> BoardPostContentData? {
        getPostContentCalled = true
        getPostContentArgs = (boardName, postId)
        return try getPostContentResult.get()
    }
}
```

## What to Test

### Must Test (필수)

| Layer | 대상 | 이유 |
|---|---|---|
| ViewModel | 상태 변화 (isLoading, errorMessage, 데이터) | UI에 직접 영향 |
| ViewModel | 로그인/비로그인 분기 | 핵심 비즈니스 로직 |
| UseCase | Result 성공/실패 분기 | 에러 핸들링 |
| UseCase | 입력 검증 | 잘못된 데이터 방어 |
| Repository | 데이터 매핑 (Data → Entity) | 타입 변환 오류 |

### Should Test (권장)

| Layer | 대상 |
|---|---|
| ViewModel | 로딩 상태 전환 순서 |
| UseCase | 빈 데이터 처리 |
| Repository | nil/빈 응답 처리 |

### Skip (불필요)

- SwiftUI View 레이아웃 (Preview로 확인)
- FirebaseDataSource 직접 호출 (통합 테스트 영역)
- SQLiteDatabaseCommands 정적 메서드 (순수 함수)

## Async Testing

```swift
// async/await 테스트
func test_loadTrends_setsData() async {
    await sut.loadTrends()
    XCTAssertNotNil(sut.trends)
}

// 타임아웃이 필요한 경우
func test_search_completesInTime() async {
    let expectation = XCTestExpectation(description: "Search completes")
    Task {
        await sut.search()
        expectation.fulfill()
    }
    await fulfillment(of: [expectation], timeout: 5.0)
}
```

## Test Coverage Targets

| Layer | Target |
|---|---|
| ViewModels | 80%+ |
| UseCases | 90%+ |
| Repositories | 70%+ |
| Data layer | 0% (integration only) |
| SwiftUI Views | 0% (preview only) |

## Running Tests

```bash
# 전체 테스트
xcodebuild test -workspace Somlimee.xcworkspace -scheme Somlimee \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'

# 특정 테스트 클래스
xcodebuild test -workspace Somlimee.xcworkspace -scheme Somlimee \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:SomlimeeTests/ProfileViewModelTests
```

## Rules

**DO:**
- Given/When/Then 패턴 사용
- 테스트당 하나의 assertion 주제
- Mock은 프로토콜 기반으로 직접 작성
- 새 ViewModel/UseCase 작성 시 테스트 동시 작성
- `setUp()`에서 SUT 생성, `tearDown()`에서 nil

**DON'T:**
- 실제 Firebase/SQLite 호출 (Mock 사용)
- 테스트 간 상태 공유
- sleep/delay로 비동기 대기 (async/await 또는 expectation 사용)
- private 메서드 직접 테스트 (public 인터페이스로 간접 테스트)
- 구현 세부사항 테스트 (결과만 검증)
