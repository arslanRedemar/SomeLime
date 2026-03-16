//
//  QuestionRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/01/25.
//

import Foundation

protocol QuestionsRepository {
    func getQuestions() async throws -> PersonalityTestQuestions?
}

class QuestionsRepositoryImpl: QuestionsRepository{
    private let dataSource: DataSource

    init(dataSource: DataSource){
        self.dataSource = dataSource
    }

    func getQuestions() async throws -> PersonalityTestQuestions?{
        Log.repo.debug("[QuestionsRepositoryImpl.getQuestions] Fetching personality test questions")
        do {
            let rawData = try await dataSource.getQuestions()
            guard let unwrappedRawData = rawData?["questions"] else{
                Log.repo.debug("[QuestionsRepositoryImpl.getQuestions] No questions found in raw data")
                return nil
            }
            let castedRawData = unwrappedRawData as? [String]
            guard let unwrappedCastedRawData = castedRawData else {
                Log.repo.debug("[QuestionsRepositoryImpl.getQuestions] Questions data casting failed")
                return nil
            }
            guard let unwrappedRawData2 = rawData?["category"] else{
                Log.repo.debug("[QuestionsRepositoryImpl.getQuestions] No category found in raw data")
                return nil
            }
            let castedRawData2 = unwrappedRawData2 as? [Four]
            guard let unwrappedCastedRawData2 = castedRawData2 else {
                Log.repo.debug("[QuestionsRepositoryImpl.getQuestions] Category data casting failed")
                return nil
            }
            Log.repo.debug("[QuestionsRepositoryImpl.getQuestions] Successfully fetched \(unwrappedCastedRawData.count) questions")
            return PersonalityTestQuestions(questions: unwrappedCastedRawData, category: unwrappedCastedRawData2, answers: [Answer.Neutral])
        } catch {
            Log.repo.error("[QuestionsRepositoryImpl.getQuestions] Failed — \(error.localizedDescription)")
            throw error
        }
    }
}
