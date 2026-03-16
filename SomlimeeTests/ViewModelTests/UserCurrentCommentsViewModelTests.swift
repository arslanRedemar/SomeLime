//
//  UserCurrentCommentsViewModelTests.swift
//  SomlimeeTests
//

@testable import Somlimee
import XCTest

final class UserCurrentCommentsViewModelTests: XCTestCase {
    private var mockUserRepo: MockUserRepository!
    private var mockAuthRepo: MockAuthRepository!
    private var sut: UserCurrentCommentsViewModelImpl!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserRepository()
        mockAuthRepo = MockAuthRepository()
        sut = UserCurrentCommentsViewModelImpl(userRepo: mockUserRepo, authRepo: mockAuthRepo)
    }

    override func tearDown() {
        mockUserRepo = nil
        mockAuthRepo = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Not Logged In Tests

    func testLoadCommentsNotLoggedIn() async {
        mockAuthRepo.currentUserID = nil

        await sut.loadComments()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.comments?.list.count, 0)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockUserRepo.getUserCommentsCallCount, 0)
    }

    // MARK: - Success Tests

    func testLoadCommentsSuccess() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserCommentsResult = [TestFixtures.makeBoardPostCommentData()]

        await sut.loadComments()

        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.comments?.list.count, 1)
        XCTAssertEqual(sut.comments?.list[0].text, "Test comment")
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockUserRepo.getUserCommentsCallCount, 1)
    }

    func testLoadCommentsEmpty() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserCommentsResult = []

        await sut.loadComments()

        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.comments?.list.count, 0)
    }

    func testLoadCommentsMultiple() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserCommentsResult = [
            TestFixtures.makeBoardPostCommentData(text: "Comment 1"),
            TestFixtures.makeBoardPostCommentData(text: "Comment 2"),
            TestFixtures.makeBoardPostCommentData(text: "Comment 3")
        ]

        await sut.loadComments()

        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.comments?.list.count, 3)
        XCTAssertEqual(sut.comments?.list[0].text, "Comment 1")
        XCTAssertEqual(sut.comments?.list[1].text, "Comment 2")
        XCTAssertEqual(sut.comments?.list[2].text, "Comment 3")
    }

    func testLoadCommentsConvertsIsRevisedCorrectly() async {
        mockAuthRepo.currentUserID = "user1"
        let revisedComment = BoardPostCommentData(
            userName: "User",
            userID: "u1",
            postID: "p1",
            target: "",
            publishedTime: "2024",
            isRevised: "Yes",
            text: "Revised comment"
        )
        mockUserRepo.getUserCommentsResult = [revisedComment]

        await sut.loadComments()

        XCTAssertEqual(sut.comments?.list.count, 1)
        XCTAssertTrue(sut.comments?.list[0].isRevised == true)
    }

    // MARK: - Failure Tests

    func testLoadCommentsFailure() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserCommentsError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])

        await sut.loadComments()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.comments?.list.count, 0)
    }

    // MARK: - Loading State Tests

    func testLoadCommentsSetsLoadingState() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserCommentsResult = []

        let task = Task {
            await sut.loadComments()
        }

        await task.value
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadCommentsClearsErrorMessageOnStart() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserCommentsResult = []
        sut.errorMessage = "Previous error"

        await sut.loadComments()

        XCTAssertNil(sut.errorMessage)
    }
}
