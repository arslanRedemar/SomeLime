@testable import Somlimee
import XCTest

final class UCSearchTests: XCTestCase {
    private var mockSearchRepo: MockSearchRepository!
    private var sut: UCSearchImpl!

    override func setUp() {
        super.setUp()
        mockSearchRepo = MockSearchRepository()
        sut = UCSearchImpl(searchRepository: mockSearchRepo)
    }

    // MARK: - execute

    func testExecuteSuccessReturnsGroupedResults() async {
        let items = [
            TestFixtures.makeSearchResultItem(postID: "p1", title: "Post A", boardName: "board1"),
            TestFixtures.makeSearchResultItem(postID: "p2", title: "Post B", boardName: "board2"),
            TestFixtures.makeSearchResultItem(postID: "p3", title: "Post C", boardName: "board1"),
        ]
        mockSearchRepo.searchPostsResult = items

        let result = await sut.execute(query: "Post", boardName: nil, scope: .title)

        switch result {
        case .success(let searchResult):
            XCTAssertEqual(searchResult.query, "Post")
            XCTAssertEqual(searchResult.items.count, 3)
            XCTAssertEqual(searchResult.groupedByBoard.count, 2)
            XCTAssertEqual(searchResult.groupedByBoard["board1"]?.count, 2)
            XCTAssertEqual(searchResult.groupedByBoard["board2"]?.count, 1)
        case .failure:
            XCTFail("Expected success")
        }
    }

    func testExecuteFailsForEmptyQuery() async {
        let result = await sut.execute(query: "", boardName: nil, scope: .title)

        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCSearchFailures)
        }
    }

    func testExecuteFailsForWhitespaceOnlyQuery() async {
        let result = await sut.execute(query: "   ", boardName: nil, scope: .title)

        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCSearchFailures)
        }
    }

    func testExecuteTrimsQueryWhitespace() async {
        mockSearchRepo.searchPostsResult = []

        _ = await sut.execute(query: "  hello  ", boardName: nil, scope: .title)

        XCTAssertEqual(mockSearchRepo.lastSearchQuery, "hello")
    }

    func testExecutePassesBoardNameToRepository() async {
        mockSearchRepo.searchPostsResult = []

        _ = await sut.execute(query: "test", boardName: "myBoard", scope: .content)

        XCTAssertEqual(mockSearchRepo.lastSearchBoardName, "myBoard")
        XCTAssertEqual(mockSearchRepo.lastSearchScope, .content)
    }

    func testExecuteReturnsFailureOnRepositoryError() async {
        mockSearchRepo.searchPostsError = DataSourceFailures.CouldNotFindDocument

        let result = await sut.execute(query: "test", boardName: nil, scope: .title)

        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCSearchFailures)
        }
    }

    func testExecuteReturnsEmptyResultsForNoMatches() async {
        mockSearchRepo.searchPostsResult = []

        let result = await sut.execute(query: "nonexistent", boardName: nil, scope: .title)

        switch result {
        case .success(let searchResult):
            XCTAssertTrue(searchResult.items.isEmpty)
            XCTAssertTrue(searchResult.groupedByBoard.isEmpty)
        case .failure:
            XCTFail("Expected success with empty results")
        }
    }
}
