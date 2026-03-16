//
//  ReportViewModelTests.swift
//  SomlimeeTests
//

@testable import Somlimee
import XCTest

final class ReportViewModelTests: XCTestCase {
    private var mockReportUC: MockUCReportContent!
    private var sut: ReportViewModelImpl!

    override func setUp() {
        super.setUp()
        mockReportUC = MockUCReportContent()
        sut = ReportViewModelImpl(reportUC: mockReportUC)
    }

    override func tearDown() {
        mockReportUC = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertEqual(sut.selectedReason, .spam)
        XCTAssertEqual(sut.detailText, "")
        XCTAssertFalse(sut.isSubmitting)
        XCTAssertFalse(sut.isSubmitted)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Submit Report Tests

    func testSubmitReportSuccess() async {
        sut.selectedReason = .harassment
        sut.detailText = "test detail"

        await sut.submitReport(boardName: "board1", postId: "p1")

        XCTAssertTrue(sut.isSubmitted)
        XCTAssertFalse(sut.isSubmitting)
        XCTAssertNil(sut.errorMessage)
        XCTAssertEqual(mockReportUC.reportCallCount, 1)
        XCTAssertEqual(mockReportUC.lastForm?.reason, .harassment)
        XCTAssertEqual(mockReportUC.lastForm?.detail, "test detail")
        XCTAssertEqual(mockReportUC.lastForm?.boardName, "board1")
        XCTAssertEqual(mockReportUC.lastForm?.targetId, "p1")
    }

    func testSubmitReportSuccessWithSpamReason() async {
        sut.selectedReason = .spam
        sut.detailText = "spam content"

        await sut.submitReport(boardName: "myLimeRoom", postId: "post123")

        XCTAssertTrue(sut.isSubmitted)
        XCTAssertEqual(mockReportUC.lastForm?.reason, .spam)
        XCTAssertEqual(mockReportUC.lastForm?.detail, "spam content")
    }

    func testSubmitReportFailure() async {
        mockReportUC.reportResult = .failure(NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"]))

        await sut.submitReport(boardName: "board1", postId: "p1")

        XCTAssertFalse(sut.isSubmitted)
        XCTAssertFalse(sut.isSubmitting)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testSubmitReportClearsErrorMessageBeforeSubmit() async {
        sut.errorMessage = "Previous error"

        await sut.submitReport(boardName: "board1", postId: "p1")

        // Should be nil on success
        XCTAssertNil(sut.errorMessage)
    }

    func testSubmitReportSetsSubmittingState() async {
        let task = Task {
            await sut.submitReport(boardName: "board1", postId: "p1")
        }

        await task.value
        XCTAssertFalse(sut.isSubmitting)
    }
}
