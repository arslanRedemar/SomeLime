//
//  ProfileViewModel.swift
//  Somlimee
//
//  Created by Chanhee on 2024/03/11.
//

import Foundation

protocol ProfileViewModel {
    var userProfile: UserProfile? { get }
    var testResult: LimeTestResult? { get }
    var testReport: LimeTestReport? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    func loadProfile() async
    func loadTestResult() async
    func loadTestReport() async
    func signOut()
}

@Observable
final class ProfileViewModelImpl: ProfileViewModel {
    var userProfile: UserProfile?
    var testResult: LimeTestResult?
    var testReport: LimeTestReport?
    var isLoading = false
    var errorMessage: String?

    private let userRepo: UserRepository
    private let personalityTestRepo: PersonalityTestRepository
    private let authRepo: AuthRepository

    init(userRepo: UserRepository, personalityTestRepo: PersonalityTestRepository, authRepo: AuthRepository) {
        self.userRepo = userRepo
        self.personalityTestRepo = personalityTestRepo
        self.authRepo = authRepo
    }

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        do {
            guard let data = try await userRepo.getUserData() else { return }
            userProfile = UserProfile(userName: data.userName, userID: authRepo.currentUserID ?? "", userSignedDate: data.signUpDate, userPoints: data.points, numOfPosts: data.numOfPosts, numOfReceivedVotes: data.receivedUps, numOfComments: 0, numOfActiveDays: data.daysOfActive)
        } catch {
            errorMessage = "프로필을 불러올 수 없습니다"
        }
    }

    func loadTestResult() async {
        do {
            guard let data = try await personalityTestRepo.getPersonalityTestResult() else { return }
            let desc = SomeLiMePTTypeDesc.typeDesc[data.type] ?? ""
            testResult = LimeTestResult(str: data.Strenuousness, rec: data.Receptiveness, har: data.Harmonization, coa: data.Coagulation, typeName: data.type, typeDesc: desc)
        } catch {
            errorMessage = "테스트 결과를 불러올 수 없습니다"
        }
    }

    func loadTestReport() async {
        do {
            guard let data = try await personalityTestRepo.getPersonalityTestResult() else { return }
            let desc = SomeLiMePTTypeDesc.typeDesc[data.type] ?? ""
            testReport = LimeTestReport(typeName: data.type, typeDetailedReport: desc, typeImageName: data.type)
        } catch {
            errorMessage = "테스트 리포트를 불러올 수 없습니다"
        }
    }

    func signOut() {
        try? authRepo.signOut()
        userProfile = nil
        testResult = nil
        testReport = nil
    }
}
