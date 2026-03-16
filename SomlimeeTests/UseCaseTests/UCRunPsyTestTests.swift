@testable import Somlimee
import XCTest

final class UCRunPsyTestTests: XCTestCase {
    private var mockQuestionsRepo: MockQuestionsRepository!
    private var mockPersonalityTestRepo: MockPersonalityTestRepository!
    private var sut: UCRunPsyTestImpl!

    override func setUp() {
        super.setUp()
        mockQuestionsRepo = MockQuestionsRepository()
        mockPersonalityTestRepo = MockPersonalityTestRepository()
        sut = UCRunPsyTestImpl(
            questionsRepo: mockQuestionsRepo,
            personalityTestRepo: mockPersonalityTestRepo
        )
    }

    // MARK: - loadQuestions

    func testLoadQuestionsSuccess() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockQuestionsRepo.getQuestionsResult = testQuestions

        let result = await sut.loadQuestions()

        switch result {
        case .success(let questions):
            XCTAssertEqual(questions.questions.count, 3)
            XCTAssertEqual(questions.category.count, 3)
        case .failure:
            XCTFail("Expected success")
        }
        XCTAssertEqual(mockQuestionsRepo.getQuestionsCallCount, 1)
    }

    func testLoadQuestionsFailsWhenRepoReturnsNil() async {
        mockQuestionsRepo.getQuestionsResult = nil

        let result = await sut.loadQuestions()

        switch result {
        case .success:
            XCTFail("Expected failure")
        case .failure(let error):
            XCTAssertTrue(error is UCRunPsyTestFailures)
        }
    }

    // MARK: - calculateResult

    func testCalculateResultWithAllAgreeOnFireCategory() {
        let answers: [Answer] = [.StronglyAgree, .Agree, .Neutral]
        let categories: [Four] = [.Fire, .Fire, .Fire]

        let result = sut.calculateResult(answers: answers, categories: categories)

        XCTAssertEqual(result.Strenuousness, 3) // 2 + 1 + 0
        XCTAssertEqual(result.Receptiveness, 0)
        XCTAssertEqual(result.Harmonization, 0)
        XCTAssertEqual(result.Coagulation, 0)
        XCTAssertTrue(result.type.hasPrefix("S")) // Strenuousness dominant
    }

    func testCalculateResultWithMixedCategories() {
        let answers: [Answer] = [.StronglyAgree, .StronglyAgree, .StronglyDisagree, .Neutral]
        let categories: [Four] = [.Fire, .Water, .Air, .Earth]

        let result = sut.calculateResult(answers: answers, categories: categories)

        XCTAssertEqual(result.Strenuousness, 2)
        XCTAssertEqual(result.Receptiveness, 2)
        XCTAssertEqual(result.Harmonization, -2)
        XCTAssertEqual(result.Coagulation, 0)
        // Fire and Water tied -> dominant = N
        XCTAssertTrue(result.type.hasPrefix("N"))
    }

    func testCalculateResultWithAllNeutral() {
        let answers: [Answer] = [.Neutral, .Neutral, .Neutral]
        let categories: [Four] = [.Fire, .Water, .Air]

        let result = sut.calculateResult(answers: answers, categories: categories)

        XCTAssertEqual(result.Strenuousness, 0)
        XCTAssertEqual(result.Receptiveness, 0)
        XCTAssertEqual(result.Harmonization, 0)
        XCTAssertEqual(result.Coagulation, 0)
        XCTAssertTrue(result.type.hasPrefix("N"))
    }

    func testCalculateResultTypeCodeFormat() {
        let answers: [Answer] = [.StronglyAgree, .Neutral, .Neutral]
        let categories: [Four] = [.Earth, .Fire, .Water]

        let result = sut.calculateResult(answers: answers, categories: categories)

        // Type code should be 3 characters: dominant + "D" + level
        XCTAssertEqual(result.type.count, 3)
        XCTAssertTrue(result.type.hasPrefix("C")) // Coagulation (Earth) dominant
    }

    func testCalculateResultWithStronglyDisagreeAnswers() {
        let answers: [Answer] = [.StronglyDisagree, .StronglyDisagree]
        let categories: [Four] = [.Water, .Water]

        let result = sut.calculateResult(answers: answers, categories: categories)

        XCTAssertEqual(result.Receptiveness, -4)
    }

    func testCalculateResultHandlesEmptyAnswers() {
        let result = sut.calculateResult(answers: [], categories: [])

        XCTAssertEqual(result.Strenuousness, 0)
        XCTAssertEqual(result.Receptiveness, 0)
        XCTAssertEqual(result.Harmonization, 0)
        XCTAssertEqual(result.Coagulation, 0)
    }

    // MARK: - saveResult

    func testSaveResultSuccess() async {
        let testResult = TestFixtures.makePersonalityTestResult()

        let result = await sut.saveResult(testResult, uid: "user123")

        switch result {
        case .success:
            XCTAssertEqual(mockPersonalityTestRepo.updatePersonalityTestCallCount, 1)
        case .failure:
            XCTFail("Expected success")
        }
    }
}
