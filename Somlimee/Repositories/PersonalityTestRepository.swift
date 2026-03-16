//
//  PersonalityTestRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/01/25.
//

import Foundation

protocol PersonalityTestRepository {
    func updatePersonalityTest(test: PersonalityTestResultData, uid: String) async throws -> Void
    func getPersonalityTestResult() async throws -> PersonalityTestResultData?
}

class PersonalityTestRepositoryImpl: PersonalityTestRepository{
    private let dataSource: DataSource

    init(dataSource: DataSource){
        self.dataSource = dataSource
    }

    func updatePersonalityTest(test: PersonalityTestResultData, uid: String) async throws -> Void{
        Log.repo.info("[PersonalityTestRepositoryImpl.updatePersonalityTest] Updating personality test for uid=\(uid) type=\(test.type)")
        do {
            guard var userData = try await dataSource.getUserData() else {
                Log.repo.debug("[PersonalityTestRepositoryImpl.updatePersonalityTest] No user data found, skipping update")
                return
            }
            userData["PersonalityTestResult"] = [test.Strenuousness, test.Receptiveness, test.Harmonization, test.Coagulation]
            userData["PersonalityType"] = test.type
            try await dataSource.updateUser(userInfo: userData)
            Log.repo.info("[PersonalityTestRepositoryImpl.updatePersonalityTest] Successfully updated personality test")
        } catch {
            Log.repo.error("[PersonalityTestRepositoryImpl.updatePersonalityTest] Failed — \(error.localizedDescription)")
            throw error
        }
    }

    func getPersonalityTestResult() async throws -> PersonalityTestResultData? {
        Log.repo.debug("[PersonalityTestRepositoryImpl.getPersonalityTestResult] Fetching personality test result")
        do {
            guard let data = try await dataSource.getUserData() else {
                Log.repo.debug("[PersonalityTestRepositoryImpl.getPersonalityTestResult] No user data found")
                return nil
            }
            let profile = try DictionaryDecoder.decode(ProfileData.self, from: data)
            Log.repo.debug("[PersonalityTestRepositoryImpl.getPersonalityTestResult] Successfully fetched personality test result")
            return profile.personalityTestResult
        } catch {
            Log.repo.error("[PersonalityTestRepositoryImpl.getPersonalityTestResult] Failed — \(error.localizedDescription)")
            throw error
        }
    }
}
