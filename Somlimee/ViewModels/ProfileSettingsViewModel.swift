//
//  ProfileSettingsViewModel.swift
//  Somlimee
//

import Foundation

protocol ProfileSettingsViewModel {
    var nickname: String { get set }
    var email: String { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var successMessage: String? { get }
    func loadProfile() async
    func updateNickname() async
    func deleteAccount(email: String, password: String) async -> Bool
}

@Observable
final class ProfileSettingsViewModelImpl: ProfileSettingsViewModel {
    var nickname = ""
    var email = ""
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    private let userRepo: UserRepository
    private let authRepo: AuthRepository

    init(userRepo: UserRepository, authRepo: AuthRepository) {
        self.userRepo = userRepo
        self.authRepo = authRepo
    }

    func loadProfile() async {
        Log.vm.debug("ProfileSettingsViewModel.loadProfile: start")
        isLoading = true
        defer { isLoading = false }
        email = authRepo.currentUserEmail ?? ""
        guard let data = try? await userRepo.getUserData() else {
            Log.vm.error("ProfileSettingsViewModel.loadProfile: failed to load user data")
            return
        }
        nickname = data.userName
        Log.vm.debug("ProfileSettingsViewModel.loadProfile: success")
    }

    func updateNickname() async {
        guard !nickname.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "닉네임을 입력해주세요."
            return
        }
        Log.vm.info("ProfileSettingsViewModel.updateNickname: new nickname=\(self.nickname)")
        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }
        do {
            try await userRepo.updateNickname(nickname)
            Log.vm.info("ProfileSettingsViewModel.updateNickname: success")
            successMessage = "닉네임이 변경되었습니다."
        } catch {
            Log.vm.error("ProfileSettingsViewModel.updateNickname: failed — \(error)")
            errorMessage = "닉네임 변경에 실패했습니다."
        }
    }

    func deleteAccount(email: String, password: String) async -> Bool {
        Log.vm.info("ProfileSettingsViewModel.deleteAccount: user action")
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authRepo.reauthenticate(email: email, password: password)
            try await userRepo.deleteUserData()
            try await authRepo.deleteAccount()
            Log.vm.info("ProfileSettingsViewModel.deleteAccount: success")
            return true
        } catch UserProfileFailures.reauthenticationRequired {
            Log.vm.error("ProfileSettingsViewModel.deleteAccount: reauth failed")
            errorMessage = "자격 증명이 올바르지 않습니다. 다시 시도해주세요."
            return false
        } catch {
            Log.vm.error("ProfileSettingsViewModel.deleteAccount: failed — \(error)")
            errorMessage = "계정 삭제에 실패했습니다."
            return false
        }
    }
}
