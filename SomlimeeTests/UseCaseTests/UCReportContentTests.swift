//
//  UCReportContentTests.swift
//  SomlimeeTests
//

@testable import Somlimee
import XCTest

final class UCReportContentTests: XCTestCase {
    private var mockReportRepo: MockReportRepository!
    private var sut: UCReportContentImpl!

    override func setUp() {
        super.setUp()
        mockReportRepo = MockReportRepository()
        sut = UCReportContentImpl(reportRepository: mockReportRepo)
    }

    override func tearDown() {
        mockReportRepo = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Success Tests

    func testReportSuccess() async {
        let form = ReportForm(targetType: "post", targetId: "p1", boardName: "board1", reason: .spam, detail: "test detail")
        let result = await sut.report(form: form)

        if case .success = result {
            XCTAssertEqual(mockReportRepo.submitReportCallCount, 1)
            XCTAssertEqual(mockReportRepo.lastReason, "spam")
            XCTAssertEqual(mockReportRepo.lastDetail, "test detail")
            XCTAssertEqual(mockReportRepo.lastBoardName, "board1")
            XCTAssertEqual(mockReportRepo.lastPostId, "p1")
        } else {
            XCTFail("Expected success")
        }
    }

    func testReportSuccessWithDifferentReason() async {
        let form = ReportForm(targetType: "post", targetId: "p1", boardName: "board1", reason: .harassment, detail: "")
        let result = await sut.report(form: form)

        if case .success = result {
            XCTAssertEqual(mockReportRepo.submitReportCallCount, 1)
            XCTAssertEqual(mockReportRepo.lastReason, "harassment")
            XCTAssertEqual(mockReportRepo.lastDetail, "")
        } else {
            XCTFail("Expected success")
        }
    }

    // MARK: - Failure Tests

    func testReportFailure() async {
        mockReportRepo.submitReportError = NSError(domain: "test", code: 1)
        let form = ReportForm(targetType: "post", targetId: "p1", boardName: "board1", reason: .harassment, detail: "")
        let result = await sut.report(form: form)

        if case .failure = result {
            XCTAssertEqual(mockReportRepo.submitReportCallCount, 1)
        } else {
            XCTFail("Expected failure")
        }
    }
}
