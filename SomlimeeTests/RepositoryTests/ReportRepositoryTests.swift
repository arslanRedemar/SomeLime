//
//  ReportRepositoryTests.swift
//  SomlimeeTests
//

@testable import Somlimee
import XCTest

final class ReportRepositoryTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: ReportRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = ReportRepositoryImpl(dataSource: mockDataSource)
    }

    override func tearDown() {
        mockDataSource = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Success Tests

    func testSubmitReportCallsDataSource() async throws {
        try await sut.submitReport(boardName: "board1", postId: "p1", reason: "spam", detail: "test")

        XCTAssertEqual(mockDataSource.createReportCallCount, 1)
        XCTAssertEqual(mockDataSource.lastReportBoardName, "board1")
        XCTAssertEqual(mockDataSource.lastReportPostId, "p1")
        XCTAssertEqual(mockDataSource.lastReportReason, "spam")
    }

    func testSubmitReportWithDifferentData() async throws {
        try await sut.submitReport(boardName: "myLimeRoom", postId: "post123", reason: "harassment", detail: "detailed explanation")

        XCTAssertEqual(mockDataSource.createReportCallCount, 1)
        XCTAssertEqual(mockDataSource.lastReportBoardName, "myLimeRoom")
        XCTAssertEqual(mockDataSource.lastReportPostId, "post123")
        XCTAssertEqual(mockDataSource.lastReportReason, "harassment")
    }

    // MARK: - Failure Tests

    func testSubmitReportPropagatesError() async {
        mockDataSource.createReportError = NSError(domain: "test", code: 1)

        do {
            try await sut.submitReport(boardName: "board1", postId: "p1", reason: "spam", detail: "test")
            XCTFail("Expected error")
        } catch {
            XCTAssertEqual(mockDataSource.createReportCallCount, 1)
        }
    }
}
