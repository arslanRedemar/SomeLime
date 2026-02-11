//
//  VerifyEmailViewModel.swift
//  Somlimee
//

import Foundation

protocol VerifyEmailViewModel {
    var isVerified: Bool { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var successMessage: String? { get }
    func checkVerificationStatus() async
    func resendVerification() async
}

@Observable
final class VerifyEmailViewModelImpl: VerifyEmailViewModel {
    var isVerified = false
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    private let authRepo: AuthRepository

    init(authRepo: AuthRepository) {
        self.authRepo = authRepo
    }

    func checkVerificationStatus() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authRepo.reloadCurrentUser()
            isVerified = authRepo.isEmailVerified
            if !isVerified {
                errorMessage = "Email not yet verified. Please check your inbox."
            }
        } catch {
            errorMessage = "Failed to check verification status."
        }
    }

    func resendVerification() async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }
        do {
            try await authRepo.sendEmailVerification()
            successMessage = "Verification email sent. Check your inbox."
        } catch {
            errorMessage = "Failed to send verification email."
        }
    }
}
