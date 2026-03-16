//
//  ProfileViewModel.swift
//  Somlimee
//
//  Created by Chanhee on 2024/03/11.
//

import Foundation

protocol ProfileViewModel {
    var isLoggedIn: Bool { get }
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
    var isLoggedIn: Bool = false
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
        Log.vm.debug("ProfileViewModel.loadProfile: start")
        isLoggedIn = authRepo.isLoggedIn
        guard isLoggedIn else {
            Log.vm.debug("ProfileViewModel.loadProfile: not logged in")
            userProfile = nil
            testResult = nil
            testReport = nil
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            guard let data = try await userRepo.getUserData() else { return }
            userProfile = UserProfile(userName: data.userName, userID: authRepo.currentUserID ?? "", userSignedDate: data.signUpDate, userPoints: data.points, numOfPosts: data.numOfPosts, numOfReceivedVotes: data.receivedUps, numOfComments: 0, numOfActiveDays: data.daysOfActive)
            Log.vm.debug("ProfileViewModel.loadProfile: success — user=\(data.userName)")
        } catch {
            Log.vm.error("ProfileViewModel.loadProfile: failed — \(error)")
            errorMessage = "프로필을 불러올 수 없습니다"
        }
    }

    func loadTestResult() async {
        Log.vm.debug("ProfileViewModel.loadTestResult: start")
        do {
            guard let data = try await personalityTestRepo.getPersonalityTestResult() else { return }
            let desc = SomeLiMePTTypeDesc.typeDesc[data.type] ?? ""
            testResult = LimeTestResult(str: data.Strenuousness, rec: data.Receptiveness, har: data.Harmonization, coa: data.Coagulation, typeName: data.type, typeDesc: desc)
            Log.vm.debug("ProfileViewModel.loadTestResult: success — type=\(data.type)")
        } catch {
            Log.vm.error("ProfileViewModel.loadTestResult: failed — \(error)")
            errorMessage = "테스트 결과를 불러올 수 없습니다"
        }
    }

    func loadTestReport() async {
        Log.vm.debug("ProfileViewModel.loadTestReport: start")
        do {
            guard let data = try await personalityTestRepo.getPersonalityTestResult() else { return }
            let desc = SomeLiMePTTypeDesc.typeDesc[data.type] ?? ""
            testReport = LimeTestReport(typeName: data.type, typeDetailedReport: desc, typeImageName: data.type)
            Log.vm.debug("ProfileViewModel.loadTestReport: success")
        } catch {
            Log.vm.error("ProfileViewModel.loadTestReport: failed — \(error)")
            errorMessage = "테스트 리포트를 불러올 수 없습니다"
        }
    }

    func signOut() {
        Log.vm.info("ProfileViewModel.signOut: user action")
        try? authRepo.signOut()
        userProfile = nil
        testResult = nil
        testReport = nil
        NotificationCenter.default.post(name: .authStateDidChange, object: nil)
    }
}
