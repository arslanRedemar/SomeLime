//
//  ChangePasswordViewModel.swift
//  Somlimee
//

import Foundation

protocol ChangePasswordViewModel {
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var successMessage: String? { get }
    func changePassword(email: String, currentPassword: String, newPassword: String, confirmPassword: String) async -> Bool
}

@Observable
final class ChangePasswordViewModelImpl: ChangePasswordViewModel {
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    private let authRepo: AuthRepository

    init(authRepo: AuthRepository) {
        self.authRepo = authRepo
    }

    func changePassword(email: String, currentPassword: String, newPassword: String, confirmPassword: String) async -> Bool {
        errorMessage = nil
        successMessage = nil

        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match."
            return false
        }
        guard newPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        Log.vm.info("ChangePasswordViewModel.changePassword: user action")
        isLoading = true
        defer { isLoading = false }
        do {
            try await authRepo.reauthenticate(email: email, password: currentPassword)
            try await authRepo.updatePassword(newPassword: newPassword)
            Log.vm.info("ChangePasswordViewModel.changePassword: success")
            successMessage = "Password updated successfully."
            return true
        } catch UserProfileFailures.reauthenticationRequired {
            Log.vm.error("ChangePasswordViewModel.changePassword: reauth failed")
            errorMessage = "Current password is incorrect."
            return false
        } catch {
            Log.vm.error("ChangePasswordViewModel.changePassword: failed — \(error)")
            errorMessage = "Failed to update password."
            return false
        }
    }
}
