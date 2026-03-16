//
//  BoardPostViewModelTests.swift
//  SomlimeeTests
//

@testable import Somlimee
import XCTest

final class BoardPostViewModelTests: XCTestCase {
    private var mockGetPost: MockUCGetPost!
    private var mockGetComments: MockUCGetComments!
    private var mockWriteComment: MockUCWriteComment!
    private var mockRecommendPost: MockUCRecommendPost!
    private var sut: BoardPostViewModelImpl!

    override func setUp() {
        super.setUp()
        mockGetPost = MockUCGetPost()
        mockGetComments = MockUCGetComments()
        mockWriteComment = MockUCWriteComment()
        mockRecommendPost = MockUCRecommendPost()
        sut = BoardPostViewModelImpl(
            getPost: mockGetPost,
            getComments: mockGetComments,
            writeComment: mockWriteComment,
            recommendPost: mockRecommendPost
        )
    }

    override func tearDown() {
        mockGetPost = nil
        mockGetComments = nil
        mockWriteComment = nil
        mockRecommendPost = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Load Post Tests

    func testLoadPostSuccess() async {
        mockGetPost.getPostMetaResult = .success(TestFixtures.makeLimeRoomPostMeta())
        mockGetPost.getPostContentResult = .success(TestFixtures.makeLimeRoomPostContent())

        await sut.loadPost(boardName: "board1", postId: "p1")

        XCTAssertNotNil(sut.meta)
        XCTAssertNotNil(sut.content)
        XCTAssertEqual(sut.meta?.title, "Test Post")
        XCTAssertEqual(sut.content?.paragraph, "Test paragraph")
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadPostMetaFailure() async {
        mockGetPost.getPostMetaResult = .failure(UCGetPostFailures.EmptyData)
        mockGetPost.getPostContentResult = .success(TestFixtures.makeLimeRoomPostContent())

        await sut.loadPost(boardName: "board1", postId: "p1")

        XCTAssertNil(sut.meta)
        XCTAssertNotNil(sut.content)
    }

    func testLoadPostContentFailure() async {
        mockGetPost.getPostMetaResult = .success(TestFixtures.makeLimeRoomPostMeta())
        mockGetPost.getPostContentResult = .failure(UCGetPostFailures.EmptyData)

        await sut.loadPost(boardName: "board1", postId: "p1")

        XCTAssertNotNil(sut.meta)
        XCTAssertNil(sut.content)
    }

    func testLoadPostSetsLoadingState() async {
        mockGetPost.getPostMetaResult = .success(TestFixtures.makeLimeRoomPostMeta())
        mockGetPost.getPostContentResult = .success(TestFixtures.makeLimeRoomPostContent())

        let task = Task {
            await sut.loadPost(boardName: "board1", postId: "p1")
        }

        await task.value
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Load Comments Tests

    func testLoadComments() async {
        mockGetComments.getCommentsResult = .success([TestFixtures.makeLimeRoomPostComment()])

        await sut.loadComments(boardName: "board1", postId: "p1")

        XCTAssertEqual(sut.comments.count, 1)
        XCTAssertEqual(sut.comments[0].text, "Test comment")
    }

    func testLoadCommentsEmpty() async {
        mockGetComments.getCommentsResult = .success([])

        await sut.loadComments(boardName: "board1", postId: "p1")

        XCTAssertEqual(sut.comments.count, 0)
    }

    func testLoadCommentsFailure() async {
        mockGetComments.getCommentsResult = .failure(NSError(domain: "test", code: 1))

        await sut.loadComments(boardName: "board1", postId: "p1")

        XCTAssertEqual(sut.comments.count, 0)
    }

    // MARK: - Submit Comment Tests

    func testSubmitCommentReloadsComments() async {
        mockWriteComment.writeCommentResult = .success(())
        mockGetComments.getCommentsResult = .success([TestFixtures.makeLimeRoomPostComment(text: "New")])

        await sut.submitComment(boardName: "board1", postId: "p1", text: "New")

        XCTAssertEqual(mockWriteComment.writeCommentCallCount, 1)
        XCTAssertEqual(mockGetComments.getCommentsCallCount, 1)
        XCTAssertEqual(sut.comments.count, 1)
        XCTAssertFalse(sut.isSubmittingComment)
    }

    func testSubmitCommentFailureDoesNotReloadComments() async {
        mockWriteComment.writeCommentResult = .failure(NSError(domain: "test", code: 1))

        await sut.submitComment(boardName: "board1", postId: "p1", text: "New")

        XCTAssertEqual(mockWriteComment.writeCommentCallCount, 1)
        XCTAssertEqual(mockGetComments.getCommentsCallCount, 0)
    }

    func testSubmitCommentSetsSubmittingState() async {
        mockWriteComment.writeCommentResult = .success(())
        mockGetComments.getCommentsResult = .success([])

        let task = Task {
            await sut.submitComment(boardName: "board1", postId: "p1", text: "Test")
        }

        await task.value
        XCTAssertFalse(sut.isSubmittingComment)
    }

    // MARK: - Vote Up Tests

    func testVoteUpSuccess() async {
        sut.meta = TestFixtures.makeLimeRoomPostMeta()
        let originalVotes = sut.meta!.numOfVotes

        await sut.voteUp(boardName: "board1", postId: "p1")

        XCTAssertTrue(sut.hasVoted)
        XCTAssertEqual(sut.meta?.numOfVotes, originalVotes + 1)
        XCTAssertEqual(mockRecommendPost.recommendPostCallCount, 1)
    }

    func testVoteUpFailureKeepsHasVotedFalse() async {
        mockRecommendPost.recommendPostResult = .failure(NSError(domain: "test", code: 1))

        await sut.voteUp(boardName: "board1", postId: "p1")

        XCTAssertFalse(sut.hasVoted)
    }

    func testVoteUpPreventsDuplicateVote() async {
        sut.meta = TestFixtures.makeLimeRoomPostMeta()

        await sut.voteUp(boardName: "board1", postId: "p1")
        await sut.voteUp(boardName: "board1", postId: "p1")

        XCTAssertEqual(mockRecommendPost.recommendPostCallCount, 1)
    }

    func testVoteUpWithNilMeta() async {
        sut.meta = nil

        await sut.voteUp(boardName: "board1", postId: "p1")

        XCTAssertTrue(sut.hasVoted)
        XCTAssertNil(sut.meta)
    }
}
