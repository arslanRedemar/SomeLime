@testable import Somlimee
import XCTest

final class SearchViewModelTests: XCTestCase {
    private var mockSearchUC: MockUCSearch!
    private var sut: SearchViewModelImpl!

    override func setUp() {
        super.setUp()
        mockSearchUC = MockUCSearch()
        sut = SearchViewModelImpl(searchUC: mockSearchUC)
    }

    // MARK: - Initial State

    func testInitialState() {
        XCTAssertEqual(sut.searchText, "")
        XCTAssertTrue(sut.results.isEmpty)
        XCTAssertTrue(sut.groupedResults.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.hasSearched)
        XCTAssertNil(sut.errorMessage)
    }

    func testInitialScopeIsTitle() {
        switch sut.scope {
        case .title:
            break // expected
        default:
            XCTFail("Expected initial scope to be .title")
        }
    }

    // MARK: - search

    func testSearchSuccessPopulatesResults() async {
        let searchResult = TestFixtures.makeSearchResult(
            query: "hello",
            items: [
                TestFixtures.makeSearchResultItem(postID: "p1", boardName: "board1"),
                TestFixtures.makeSearchResultItem(postID: "p2", boardName: "board2"),
            ]
        )
        mockSearchUC.executeResult = .success(searchResult)
        sut.searchText = "hello"

        await sut.search()

        XCTAssertEqual(sut.results.count, 2)
        XCTAssertEqual(sut.groupedResults.count, 2)
        XCTAssertTrue(sut.hasSearched)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testSearchDoesNothingForEmptyText() async {
        sut.searchText = ""

        await sut.search()

        XCTAssertEqual(mockSearchUC.executeCallCount, 0)
        XCTAssertFalse(sut.hasSearched)
    }

    func testSearchDoesNothingForWhitespaceOnly() async {
        sut.searchText = "   "

        await sut.search()

        XCTAssertEqual(mockSearchUC.executeCallCount, 0)
    }

    func testSearchPassesScopeToUseCase() async {
        mockSearchUC.executeResult = .success(TestFixtures.makeSearchResult())
        sut.searchText = "test"
        sut.scope = .content

        await sut.search()

        XCTAssertEqual(mockSearchUC.lastScope, .content)
    }

    func testSearchPassesBoardNameToUseCase() async {
        mockSearchUC.executeResult = .success(TestFixtures.makeSearchResult())
        sut.searchText = "test"
        sut.selectedBoard = "myBoard"

        await sut.search()

        XCTAssertEqual(mockSearchUC.lastBoardName, "myBoard")
    }

    func testSearchFailureSetsErrorMessage() async {
        mockSearchUC.executeResult = .failure(UCSearchFailures.searchFailed)
        sut.searchText = "test"

        await sut.search()

        XCTAssertTrue(sut.hasSearched)
        XCTAssertTrue(sut.results.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testSearchClearsErrorOnNewSearch() async {
        // First search fails
        mockSearchUC.executeResult = .failure(UCSearchFailures.searchFailed)
        sut.searchText = "test"
        await sut.search()
        XCTAssertNotNil(sut.errorMessage)

        // Second search succeeds
        mockSearchUC.executeResult = .success(TestFixtures.makeSearchResult())
        await sut.search()
        XCTAssertNil(sut.errorMessage)
    }

    func testSearchEmptyResultsAfterSuccess() async {
        mockSearchUC.executeResult = .success(SearchResult(query: "nope", items: [], groupedByBoard: [:]))
        sut.searchText = "nope"

        await sut.search()

        XCTAssertTrue(sut.hasSearched)
        XCTAssertTrue(sut.results.isEmpty)
        XCTAssertNil(sut.errorMessage)
    }
}
