@testable import Somlimee
import XCTest

final class QuestionsRepositoryTests: XCTestCase {
    private var mockDataSource: MockDataSource!
    private var sut: QuestionsRepositoryImpl!

    override func setUp() {
        super.setUp()
        mockDataSource = MockDataSource()
        sut = QuestionsRepositoryImpl(dataSource: mockDataSource)
    }

    func testGetQuestionsReturnsData() async throws {
        mockDataSource.getQuestionsResult = [
            "questions": ["Q1", "Q2"],
            "category": [Four.Fire, Four.Water]
        ]
        let result = try await sut.getQuestions()
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.questions, ["Q1", "Q2"])
        XCTAssertEqual(result?.category.count, 2)
    }

    func testGetQuestionsReturnsNilForNilData() async throws {
        mockDataSource.getQuestionsResult = nil
        let result = try await sut.getQuestions()
        XCTAssertNil(result)
    }

    func testGetQuestionsReturnsNilForMissingQuestionsKey() async throws {
        mockDataSource.getQuestionsResult = ["category": [Four.Fire]]
        let result = try await sut.getQuestions()
        XCTAssertNil(result)
    }

    func testGetQuestionsReturnsNilForMissingCategoryKey() async throws {
        mockDataSource.getQuestionsResult = ["questions": ["Q1"]]
        let result = try await sut.getQuestions()
        XCTAssertNil(result)
    }
}
