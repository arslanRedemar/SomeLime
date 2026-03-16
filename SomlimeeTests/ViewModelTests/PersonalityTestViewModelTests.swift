@testable import Somlimee
import XCTest

final class PersonalityTestViewModelTests: XCTestCase {
    private var mockRunPsyTest: MockUCRunPsyTest!
    private var mockAuthRepo: MockAuthRepository!
    private var sut: PersonalityTestViewModelImpl!

    override func setUp() {
        super.setUp()
        mockRunPsyTest = MockUCRunPsyTest()
        mockAuthRepo = MockAuthRepository()
        sut = PersonalityTestViewModelImpl(
            runPsyTest: mockRunPsyTest,
            authRepo: mockAuthRepo
        )
    }

    // MARK: - Initial State

    func testInitialState() {
        XCTAssertTrue(sut.questions.isEmpty)
        XCTAssertTrue(sut.answers.isEmpty)
        XCTAssertEqual(sut.currentIndex, 0)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.isCompleted)
        XCTAssertNil(sut.result)
        XCTAssertNil(sut.errorMessage)
    }

    func testInitialProgressIsZero() {
        XCTAssertEqual(sut.progress, 0)
    }

    // MARK: - loadQuestions

    func testLoadQuestionsSuccess() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockRunPsyTest.loadQuestionsResult = .success(testQuestions)

        await sut.loadQuestions()

        XCTAssertEqual(sut.questions.count, 3)
        XCTAssertEqual(sut.categories.count, 3)
        XCTAssertEqual(sut.answers.count, 3)
        XCTAssertEqual(sut.currentIndex, 0)
        XCTAssertFalse(sut.isCompleted)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadQuestionsFailure() async {
        mockRunPsyTest.loadQuestionsResult = .failure(UCRunPsyTestFailures.questionsNotFound)

        await sut.loadQuestions()

        XCTAssertTrue(sut.questions.isEmpty)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - selectAnswer

    func testSelectAnswerAdvancesIndex() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockRunPsyTest.loadQuestionsResult = .success(testQuestions)
        await sut.loadQuestions()

        sut.selectAnswer(.Agree)

        XCTAssertEqual(sut.currentIndex, 1)
    }

    func testSelectAnswerRecordsAnswer() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockRunPsyTest.loadQuestionsResult = .success(testQuestions)
        await sut.loadQuestions()

        sut.selectAnswer(.StronglyAgree)

        switch sut.answers[0] {
        case .StronglyAgree:
            break // expected
        default:
            XCTFail("Expected StronglyAgree")
        }
    }

    func testSelectAnswerOnLastQuestionCompletesTest() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockRunPsyTest.loadQuestionsResult = .success(testQuestions)
        mockRunPsyTest.calculateResultReturn = PersonalityTestResultData(
            Strenuousness: 2, Receptiveness: 0, Harmonization: 0, Coagulation: 0, type: "SDR"
        )
        await sut.loadQuestions()

        // Answer all 3 questions
        sut.selectAnswer(.Agree)
        sut.selectAnswer(.Neutral)
        sut.selectAnswer(.Disagree)

        XCTAssertTrue(sut.isCompleted)
        XCTAssertNotNil(sut.result)
        XCTAssertEqual(sut.result?.type, "SDR")
        XCTAssertEqual(mockRunPsyTest.calculateResultCallCount, 1)
    }

    func testSelectAnswerDoesNothingWhenNoQuestions() {
        sut.selectAnswer(.Agree)
        XCTAssertEqual(sut.currentIndex, 0)
    }

    // MARK: - progress

    func testProgressCalculation() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockRunPsyTest.loadQuestionsResult = .success(testQuestions)
        await sut.loadQuestions()

        XCTAssertEqual(sut.progress, 0.0, accuracy: 0.01)

        sut.selectAnswer(.Neutral)
        XCTAssertEqual(sut.progress, 1.0 / 3.0, accuracy: 0.01)

        sut.selectAnswer(.Neutral)
        XCTAssertEqual(sut.progress, 2.0 / 3.0, accuracy: 0.01)
    }

    // MARK: - currentQuestion

    func testCurrentQuestionReturnsCorrectQuestion() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockRunPsyTest.loadQuestionsResult = .success(testQuestions)
        await sut.loadQuestions()

        XCTAssertEqual(sut.currentQuestion, "질문 1")

        sut.selectAnswer(.Neutral)
        XCTAssertEqual(sut.currentQuestion, "질문 2")
    }

    func testCurrentQuestionReturnsEmptyWhenNoQuestions() {
        XCTAssertEqual(sut.currentQuestion, "")
    }

    // MARK: - goBack

    func testGoBackDecrementsIndex() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockRunPsyTest.loadQuestionsResult = .success(testQuestions)
        await sut.loadQuestions()

        sut.selectAnswer(.Neutral)
        XCTAssertEqual(sut.currentIndex, 1)

        sut.goBack()
        XCTAssertEqual(sut.currentIndex, 0)
    }

    func testGoBackDoesNothingAtFirstQuestion() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockRunPsyTest.loadQuestionsResult = .success(testQuestions)
        await sut.loadQuestions()

        sut.goBack()
        XCTAssertEqual(sut.currentIndex, 0)
    }

    // MARK: - finishTest

    func testFinishTestSavesResult() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockRunPsyTest.loadQuestionsResult = .success(testQuestions)
        mockRunPsyTest.calculateResultReturn = PersonalityTestResultData(
            Strenuousness: 2, Receptiveness: 0, Harmonization: 0, Coagulation: 0, type: "SDR"
        )
        mockAuthRepo.currentUserID = "user123"
        await sut.loadQuestions()

        // Complete the test
        sut.selectAnswer(.Agree)
        sut.selectAnswer(.Neutral)
        sut.selectAnswer(.Disagree)

        await sut.finishTest()

        XCTAssertEqual(mockRunPsyTest.saveResultCallCount, 1)
        XCTAssertEqual(mockRunPsyTest.lastSavedUid, "user123")
    }

    func testFinishTestFailsWhenNotLoggedIn() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockRunPsyTest.loadQuestionsResult = .success(testQuestions)
        mockRunPsyTest.calculateResultReturn = PersonalityTestResultData(
            Strenuousness: 2, Receptiveness: 0, Harmonization: 0, Coagulation: 0, type: "SDR"
        )
        mockAuthRepo.currentUserID = nil
        await sut.loadQuestions()

        sut.selectAnswer(.Agree)
        sut.selectAnswer(.Neutral)
        sut.selectAnswer(.Disagree)

        await sut.finishTest()

        XCTAssertEqual(mockRunPsyTest.saveResultCallCount, 0)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testFinishTestDoesNothingWithoutResult() async {
        mockAuthRepo.currentUserID = "user123"

        await sut.finishTest()

        XCTAssertEqual(mockRunPsyTest.saveResultCallCount, 0)
    }

    func testFinishTestShowsErrorOnSaveFailure() async {
        let testQuestions = TestFixtures.makePersonalityTestQuestions()
        mockRunPsyTest.loadQuestionsResult = .success(testQuestions)
        mockRunPsyTest.calculateResultReturn = PersonalityTestResultData(
            Strenuousness: 2, Receptiveness: 0, Harmonization: 0, Coagulation: 0, type: "SDR"
        )
        mockRunPsyTest.saveResultReturn = .failure(UCRunPsyTestFailures.saveFailed)
        mockAuthRepo.currentUserID = "user123"
        await sut.loadQuestions()

        sut.selectAnswer(.Agree)
        sut.selectAnswer(.Neutral)
        sut.selectAnswer(.Disagree)

        await sut.finishTest()

        XCTAssertNotNil(sut.errorMessage)
    }
}
