@testable import Somlimee
import XCTest

final class SearchRepositoryTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: SearchRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = SearchRepositoryImpl(dataSource: mockDataSource)
    }

    // MARK: - getAvailableBoards

    func testGetAvailableBoardsReturnsListFromDataSource() async throws {
        mockDataSource.getBoardListDataResult = ["list": ["board1", "board2", "board3"]]
        let boards = try await sut.getAvailableBoards()
        XCTAssertEqual(boards, ["board1", "board2", "board3"])
        XCTAssertEqual(mockDataSource.getBoardListDataCallCount, 1)
    }

    func testGetAvailableBoardsReturnsEmptyWhenNil() async throws {
        mockDataSource.getBoardListDataResult = nil
        let boards = try await sut.getAvailableBoards()
        XCTAssertTrue(boards.isEmpty)
    }

    // MARK: - searchPosts

    func testSearchPostsFiltersByTitle() async throws {
        mockDataSource.getBoardPostMetaListResult = [
            TestFixtures.makeBoardPostMetaDict(postID: "p1", title: "Swift 프로그래밍"),
            TestFixtures.makeBoardPostMetaDict(postID: "p2", title: "Java 프로그래밍"),
            TestFixtures.makeBoardPostMetaDict(postID: "p3", title: "Swift UI 개발"),
        ]

        let results = try await sut.searchPosts(
            query: "Swift",
            boardName: "board1",
            scope: .title,
            counts: 50
        )

        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].postMeta.postID, "p1")
        XCTAssertEqual(results[1].postMeta.postID, "p3")
    }

    func testSearchPostsCaseInsensitive() async throws {
        mockDataSource.getBoardPostMetaListResult = [
            TestFixtures.makeBoardPostMetaDict(postID: "p1", title: "SWIFT Programming"),
        ]

        let results = try await sut.searchPosts(
            query: "swift",
            boardName: "board1",
            scope: .title,
            counts: 50
        )

        XCTAssertEqual(results.count, 1)
    }

    func testSearchPostsAcrossAllBoardsWhenBoardNameIsNil() async throws {
        mockDataSource.getBoardListDataResult = ["list": ["boardA", "boardB"]]
        mockDataSource.getBoardPostMetaListResult = [
            TestFixtures.makeBoardPostMetaDict(postID: "p1", title: "Test Post"),
        ]

        let results = try await sut.searchPosts(
            query: "Test",
            boardName: nil,
            scope: .title,
            counts: 50
        )

        // Called for each board
        XCTAssertEqual(mockDataSource.getBoardPostMetaListCallCount, 2)
        XCTAssertEqual(results.count, 2) // Same result for each board
    }

    func testSearchPostsReturnsEmptyForNoMatch() async throws {
        mockDataSource.getBoardPostMetaListResult = [
            TestFixtures.makeBoardPostMetaDict(postID: "p1", title: "Unrelated Post"),
        ]

        let results = try await sut.searchPosts(
            query: "xyz",
            boardName: "board1",
            scope: .title,
            counts: 50
        )

        XCTAssertTrue(results.isEmpty)
    }

    func testSearchPostsReturnsEmptyWhenDataSourceReturnsNil() async throws {
        mockDataSource.getBoardPostMetaListResult = nil

        let results = try await sut.searchPosts(
            query: "test",
            boardName: "board1",
            scope: .title,
            counts: 50
        )

        XCTAssertTrue(results.isEmpty)
    }

    func testSearchPostsSetsCorrectBoardNameOnResults() async throws {
        mockDataSource.getBoardPostMetaListResult = [
            TestFixtures.makeBoardPostMetaDict(postID: "p1", title: "Match Post"),
        ]

        let results = try await sut.searchPosts(
            query: "Match",
            boardName: "myBoard",
            scope: .title,
            counts: 50
        )

        XCTAssertEqual(results.first?.boardDisplayName, "myBoard")
        XCTAssertEqual(results.first?.postMeta.boardName, "myBoard")
    }
}
