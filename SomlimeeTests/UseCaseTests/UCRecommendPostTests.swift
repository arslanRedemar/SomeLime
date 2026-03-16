//
//  UCRecommendPostTests.swift
//  SomlimeeTests
//

@testable import Somlimee
import XCTest

final class UCRecommendPostTests: XCTestCase {
    private var mockPostRepo: MockPostRepository!
    private var sut: UCRecommendPostImpl!

    override func setUp() {
        super.setUp()
        mockPostRepo = MockPostRepository()
        sut = UCRecommendPostImpl(postRepository: mockPostRepo)
    }

    override func tearDown() {
        mockPostRepo = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Success Tests

    func testRecommendPostSuccess() async {
        let result = await sut.recommendPost(boardName: "board1", postId: "p1")
        XCTAssertTrue(result.isSuccess)
        XCTAssertEqual(mockPostRepo.voteUpPostCallCount, 1)
    }

    // MARK: - Failure Tests

    func testRecommendPostFailure() async {
        mockPostRepo.voteUpPostError = NSError(domain: "test", code: 1)
        let result = await sut.recommendPost(boardName: "board1", postId: "p1")
        XCTAssertTrue(result.isFailure)
    }
}

// MARK: - Result Helpers

private extension Result {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    var isFailure: Bool {
        !isSuccess
    }
}
