//
//  UserCurrentPostsViewModelTests.swift
//  SomlimeeTests
//

@testable import Somlimee
import XCTest

final class UserCurrentPostsViewModelTests: XCTestCase {
    private var mockUserRepo: MockUserRepository!
    private var mockAuthRepo: MockAuthRepository!
    private var sut: UserCurrentPostsViewModelImpl!

    override func setUp() {
        super.setUp()
        mockUserRepo = MockUserRepository()
        mockAuthRepo = MockAuthRepository()
        sut = UserCurrentPostsViewModelImpl(userRepo: mockUserRepo, authRepo: mockAuthRepo)
    }

    override func tearDown() {
        mockUserRepo = nil
        mockAuthRepo = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Not Logged In Tests

    func testLoadPostsNotLoggedIn() async {
        mockAuthRepo.currentUserID = nil

        await sut.loadPosts()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.posts?.list.count, 0)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockUserRepo.getUserPostsCallCount, 0)
    }

    // MARK: - Success Tests

    func testLoadPostsSuccess() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserPostsResult = [TestFixtures.makeBoardPostMetaData()]

        await sut.loadPosts()

        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.posts?.list.count, 1)
        XCTAssertEqual(sut.posts?.list[0].title, "Test Post")
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(mockUserRepo.getUserPostsCallCount, 1)
    }

    func testLoadPostsEmpty() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserPostsResult = []

        await sut.loadPosts()

        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.posts?.list.count, 0)
    }

    func testLoadPostsMultiple() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserPostsResult = [
            TestFixtures.makeBoardPostMetaData(postID: "p1", title: "Post 1"),
            TestFixtures.makeBoardPostMetaData(postID: "p2", title: "Post 2"),
            TestFixtures.makeBoardPostMetaData(postID: "p3", title: "Post 3")
        ]

        await sut.loadPosts()

        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(sut.posts?.list.count, 3)
        XCTAssertEqual(sut.posts?.list[0].title, "Post 1")
        XCTAssertEqual(sut.posts?.list[1].title, "Post 2")
        XCTAssertEqual(sut.posts?.list[2].title, "Post 3")
    }

    // MARK: - Failure Tests

    func testLoadPostsFailure() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserPostsError = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])

        await sut.loadPosts()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.posts?.list.count, 0)
    }

    // MARK: - Loading State Tests

    func testLoadPostsSetsLoadingState() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserPostsResult = []

        let task = Task {
            await sut.loadPosts()
        }

        await task.value
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadPostsClearsErrorMessageOnStart() async {
        mockAuthRepo.currentUserID = "user1"
        mockUserRepo.getUserPostsResult = []
        sut.errorMessage = "Previous error"

        await sut.loadPosts()

        XCTAssertNil(sut.errorMessage)
    }
}
