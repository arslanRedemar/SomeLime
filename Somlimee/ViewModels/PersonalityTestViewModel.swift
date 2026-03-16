//
//  PersonalityTestViewModel.swift
//  Somlimee
//

import Foundation

protocol PersonalityTestViewModel {
    var questions: [String] { get }
    var categories: [Four] { get }
    var answers: [Answer] { get }
    var currentIndex: Int { get }
    var isLoading: Bool { get }
    var isCompleted: Bool { get }
    var result: PersonalityTestResultData? { get }
    var errorMessage: String? { get }
    var progress: Double { get }
    var currentQuestion: String { get }
    func loadQuestions() async
    func selectAnswer(_ answer: Answer)
    func goBack()
    func finishTest() async
}

@Observable
final class PersonalityTestViewModelImpl: PersonalityTestViewModel {
    var questions: [String] = []
    var categories: [Four] = []
    var answers: [Answer] = []
    var currentIndex = 0
    var isLoading = false
    var isCompleted = false
    var result: PersonalityTestResultData?
    var errorMessage: String?

    private let runPsyTest: UCRunPsyTest
    private let authRepo: AuthRepository

    init(runPsyTest: UCRunPsyTest, authRepo: AuthRepository) {
        self.runPsyTest = runPsyTest
        self.authRepo = authRepo
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var currentQuestion: String {
        guard currentIndex < questions.count else { return "" }
        return questions[currentIndex]
    }

    func loadQuestions() async {
        Log.vm.debug("PersonalityTestViewModel.loadQuestions: start")
        isLoading = true
        defer { isLoading = false }

        let loadResult = await runPsyTest.loadQuestions()
        switch loadResult {
        case .success(let data):
            questions = data.questions
            categories = data.category
            answers = Array(repeating: .Neutral, count: data.questions.count)
            currentIndex = 0
            isCompleted = false
            result = nil
            Log.vm.debug("PersonalityTestViewModel.loadQuestions: success — \(data.questions.count) questions")
        case .failure(let error):
            Log.vm.error("PersonalityTestViewModel.loadQuestions: failed — \(error)")
            errorMessage = "질문을 불러오는데 실패했습니다."
        }
    }

    func selectAnswer(_ answer: Answer) {
        guard currentIndex < answers.count else { return }
        Log.vm.debug("PersonalityTestViewModel.selectAnswer: q=\(self.currentIndex) answer=\(String(describing: answer))")
        answers[currentIndex] = answer

        if currentIndex < questions.count - 1 {
            currentIndex += 1
        } else {
            Log.vm.info("PersonalityTestViewModel.selectAnswer: test completed")
            let calcResult = runPsyTest.calculateResult(answers: answers, categories: categories)
            result = calcResult
            isCompleted = true
        }
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        Log.vm.debug("PersonalityTestViewModel.goBack: from \(self.currentIndex) to \(self.currentIndex - 1)")
        currentIndex -= 1
    }

    func finishTest() async {
        guard let result = result else { return }
        guard let uid = authRepo.currentUserID else {
            errorMessage = "로그인이 필요합니다."
            return
        }

        Log.vm.info("PersonalityTestViewModel.finishTest: saving result")
        isLoading = true
        defer { isLoading = false }

        let saveResult = await runPsyTest.saveResult(result, uid: uid)
        if case .failure(let error) = saveResult {
            Log.vm.error("PersonalityTestViewModel.finishTest: failed — \(error)")
            errorMessage = "결과 저장에 실패했습니다."
        } else {
            Log.vm.info("PersonalityTestViewModel.finishTest: success")
        }
    }
}
