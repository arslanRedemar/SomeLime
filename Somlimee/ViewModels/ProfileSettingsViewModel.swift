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
        isLoading = true
        defer { isLoading = false }
        email = authRepo.currentUserEmail ?? ""
        guard let data = try? await userRepo.getUserData() else { return }
        nickname = data.userName
    }

    func updateNickname() async {
        guard !nickname.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Nickname cannot be empty."
            return
        }
        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }
        do {
            try await userRepo.updateNickname(nickname)
            successMessage = "Nickname updated."
        } catch {
            errorMessage = "Failed to update nickname."
        }
    }

    func deleteAccount(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authRepo.reauthenticate(email: email, password: password)
            try await userRepo.deleteUserData()
            try await authRepo.deleteAccount()
            return true
        } catch UserProfileFailures.reauthenticationRequired {
            errorMessage = "Invalid credentials. Please try again."
            return false
        } catch {
            errorMessage = "Failed to delete account."
            return false
        }
    }
}
