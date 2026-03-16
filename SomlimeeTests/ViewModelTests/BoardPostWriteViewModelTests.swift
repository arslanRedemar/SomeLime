//
//  BoardPostWriteViewModelTests.swift
//  SomlimeeTests
//

@testable import Somlimee
import XCTest

final class BoardPostWriteViewModelTests: XCTestCase {
    private var mockWritePost: MockUCWritePost!
    private var mockAuthRepo: MockAuthRepository!
    private var mockPostRepo: MockPostRepository!
    private var sut: BoardPostWriteViewModelImpl!

    override func setUp() {
        super.setUp()
        mockWritePost = MockUCWritePost()
        mockAuthRepo = MockAuthRepository()
        mockPostRepo = MockPostRepository()
        sut = BoardPostWriteViewModelImpl(
            writePost: mockWritePost,
            authRepo: mockAuthRepo,
            postRepo: mockPostRepo
        )
    }

    override func tearDown() {
        mockWritePost = nil
        mockAuthRepo = nil
        mockPostRepo = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertFalse(sut.isSubmitting)
        XCTAssertFalse(sut.isSubmitted)
        XCTAssertNil(sut.errorMessage)
        XCTAssertTrue(sut.selectedImageData.isEmpty)
    }

    // MARK: - Submit Post Tests

    func testSubmitPostSuccess() async {
        mockAuthRepo.currentUserID = "user1"

        await sut.submitPost(boardName: "board1", title: "Title", paragraph: "Content")

        XCTAssertTrue(sut.isSubmitted)
        XCTAssertEqual(mockWritePost.writePostCallCount, 1)
        XCTAssertFalse(sut.isSubmitting)
    }

    func testSubmitPostFailure() async {
        mockAuthRepo.currentUserID = "user1"
        mockWritePost.writePostResult = .failure(NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Write error"]))

        await sut.submitPost(boardName: "board1", title: "Title", paragraph: "Content")

        XCTAssertFalse(sut.isSubmitted)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testSubmitPostWithNilUserID() async {
        mockAuthRepo.currentUserID = nil

        await sut.submitPost(boardName: "board1", title: "Title", paragraph: "Content")

        XCTAssertEqual(mockWritePost.writePostCallCount, 1)
    }

    // MARK: - Image Upload Tests

    func testSubmitPostWithImagesUploads() async {
        mockAuthRepo.currentUserID = "user1"
        sut.selectedImageData = [Data([0xFF, 0xD8, 0xFF]), Data([0xFF, 0xD8, 0xFF])]

        await sut.submitPost(boardName: "board1", title: "Title", paragraph: "Content")

        XCTAssertEqual(mockPostRepo.uploadImageCallCount, 2)
        XCTAssertTrue(sut.isSubmitted)
    }

    func testSubmitPostImageUploadFailure() async {
        mockAuthRepo.currentUserID = "user1"
        mockPostRepo.uploadImageError = NSError(domain: "test", code: 1)
        sut.selectedImageData = [Data([0xFF, 0xD8, 0xFF])]

        await sut.submitPost(boardName: "board1", title: "Title", paragraph: "Content")

        XCTAssertFalse(sut.isSubmitted)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(mockWritePost.writePostCallCount, 0)
    }

    func testSubmitPostMultipleImagesStopsOnFirstFailure() async {
        mockAuthRepo.currentUserID = "user1"
        mockPostRepo.uploadImageError = NSError(domain: "test", code: 1)
        sut.selectedImageData = [Data([0xFF, 0xD8, 0xFF]), Data([0xFF, 0xD8, 0xFF])]

        await sut.submitPost(boardName: "board1", title: "Title", paragraph: "Content")

        XCTAssertFalse(sut.isSubmitted)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(mockPostRepo.uploadImageCallCount, 1)
    }

    // MARK: - Remove Image Tests

    func testRemoveImage() {
        sut.selectedImageData = [Data([1]), Data([2]), Data([3])]

        sut.removeImage(at: 1)

        XCTAssertEqual(sut.selectedImageData.count, 2)
        XCTAssertEqual(sut.selectedImageData[0], Data([1]))
        XCTAssertEqual(sut.selectedImageData[1], Data([3]))
    }

    func testRemoveImageInvalidIndex() {
        sut.selectedImageData = [Data([1])]

        sut.removeImage(at: 5)

        XCTAssertEqual(sut.selectedImageData.count, 1)
    }

    func testRemoveImageNegativeIndex() {
        sut.selectedImageData = [Data([1]), Data([2])]

        sut.removeImage(at: -1)

        XCTAssertEqual(sut.selectedImageData.count, 2)
    }

    func testRemoveImageFromEmptyArray() {
        sut.selectedImageData = []

        sut.removeImage(at: 0)

        XCTAssertEqual(sut.selectedImageData.count, 0)
    }

    // MARK: - Loading State Tests

    func testSubmitPostSetsSubmittingState() async {
        mockAuthRepo.currentUserID = "user1"

        let task = Task {
            await sut.submitPost(boardName: "board1", title: "Title", paragraph: "Content")
        }

        await task.value
        XCTAssertFalse(sut.isSubmitting)
    }

    func testSubmitPostClearsErrorMessageOnStart() async {
        mockAuthRepo.currentUserID = "user1"
        sut.errorMessage = "Previous error"

        await sut.submitPost(boardName: "board1", title: "Title", paragraph: "Content")

        // Should be nil on success
        XCTAssertNil(sut.errorMessage)
    }
}
