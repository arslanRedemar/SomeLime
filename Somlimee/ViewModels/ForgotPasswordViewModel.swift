//
//  ForgotPasswordViewModel.swift
//  Somlimee
//

import Foundation

protocol ForgotPasswordViewModel {
    var isLoading: Bool { get }
    var successMessage: String? { get }
    var errorMessage: String? { get }
    func sendPasswordReset(email: String) async
}

@Observable
final class ForgotPasswordViewModelImpl: ForgotPasswordViewModel {
    var isLoading = false
    var successMessage: String?
    var errorMessage: String?

    private let authRepo: AuthRepository

    init(authRepo: AuthRepository) {
        self.authRepo = authRepo
    }

    func sendPasswordReset(email: String) async {
        isLoading = true
        successMessage = nil
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authRepo.sendPasswordReset(email: email)
            successMessage = "Password reset email sent. Check your inbox."
        } catch {
            errorMessage = "Failed to send reset email. Please check the email address."
        }
    }
}
