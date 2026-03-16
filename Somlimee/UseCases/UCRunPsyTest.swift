//
//  UCRunPsyTest.swift
//  Somlimee
//

import Foundation

protocol UCRunPsyTest {
    func loadQuestions() async -> Result<PersonalityTestQuestions, Error>
    func calculateResult(answers: [Answer], categories: [Four]) -> PersonalityTestResultData
    func saveResult(_ result: PersonalityTestResultData, uid: String) async -> Result<Void, Error>
}

class UCRunPsyTestImpl: UCRunPsyTest {
    private let questionsRepo: QuestionsRepository
    private let personalityTestRepo: PersonalityTestRepository

    init(questionsRepo: QuestionsRepository, personalityTestRepo: PersonalityTestRepository) {
        self.questionsRepo = questionsRepo
        self.personalityTestRepo = personalityTestRepo
    }

    func loadQuestions() async -> Result<PersonalityTestQuestions, Error> {
        Log.useCase.debug("UCRunPsyTest.loadQuestions: start")
        do {
            guard let questions = try await questionsRepo.getQuestions() else {
                Log.useCase.error("UCRunPsyTest.loadQuestions: questions not found")
                return .failure(UCRunPsyTestFailures.questionsNotFound)
            }
            Log.useCase.debug("UCRunPsyTest.loadQuestions: success")
            return .success(questions)
        } catch {
            Log.useCase.error("UCRunPsyTest.loadQuestions: failed — \(error)")
            return .failure(UCRunPsyTestFailures.questionsNotFound)
        }
    }

    func calculateResult(answers: [Answer], categories: [Four]) -> PersonalityTestResultData {
        Log.useCase.debug("UCRunPsyTest.calculateResult: \(answers.count) answers")
        var scores: [Four: Int] = [.Fire: 0, .Water: 0, .Air: 0, .Earth: 0]

        for (index, answer) in answers.enumerated() {
            guard index < categories.count else { break }
            let category = categories[index]
            let value: Int
            switch answer {
            case .StronglyDisagree: value = -2
            case .Disagree: value = -1
            case .Neutral: value = 0
            case .Agree: value = 1
            case .StronglyAgree: value = 2
            }
            scores[category, default: 0] += value
        }

        let str = scores[.Fire] ?? 0
        let rec = scores[.Water] ?? 0
        let har = scores[.Air] ?? 0
        let coa = scores[.Earth] ?? 0

        let dominant = determineDominant(str: str, rec: rec, har: har, coa: coa)
        let totalScore = abs(str) + abs(rec) + abs(har) + abs(coa)
        let level = determineLevel(totalScore: totalScore, questionCount: answers.count)

        let typeCode = "\(dominant)D\(level)"

        Log.useCase.debug("UCRunPsyTest.calculateResult: result=\(typeCode)")
        return PersonalityTestResultData(
            Strenuousness: str,
            Receptiveness: rec,
            Harmonization: har,
            Coagulation: coa,
            type: typeCode
        )
    }

    func saveResult(_ result: PersonalityTestResultData, uid: String) async -> Result<Void, Error> {
        Log.useCase.info("UCRunPsyTest.saveResult: uid=\(uid) type=\(result.type)")
        do {
            try await personalityTestRepo.updatePersonalityTest(test: result, uid: uid)
            Log.useCase.info("UCRunPsyTest.saveResult: success")
            return .success(())
        } catch {
            Log.useCase.error("UCRunPsyTest.saveResult: failed — \(error)")
            return .failure(UCRunPsyTestFailures.saveFailed)
        }
    }

    private func determineDominant(str: Int, rec: Int, har: Int, coa: Int) -> String {
        let pairs: [(String, Int)] = [("S", str), ("R", rec), ("H", har), ("C", coa)]
        let sorted = pairs.sorted { $0.1 > $1.1 }

        if sorted[0].1 == sorted[1].1 {
            return "N"
        }
        return sorted[0].0
    }

    private func determineLevel(totalScore: Int, questionCount: Int) -> String {
        let maxPossible = questionCount * 2
        guard maxPossible > 0 else { return "R" }
        let ratio = Double(totalScore) / Double(maxPossible)
        if ratio < 0.33 {
            return "D"
        } else if ratio < 0.66 {
            return "R"
        } else {
            return "E"
        }
    }
}
