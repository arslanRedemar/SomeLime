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
        Log.vm.debug("VerifyEmailViewModel.checkVerificationStatus: start")
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authRepo.reloadCurrentUser()
            isVerified = authRepo.isEmailVerified
            Log.vm.debug("VerifyEmailViewModel.checkVerificationStatus: isVerified=\(self.isVerified)")
            if !isVerified {
                errorMessage = "Email not yet verified. Please check your inbox."
            }
        } catch {
            Log.vm.error("VerifyEmailViewModel.checkVerificationStatus: failed — \(error)")
            errorMessage = "Failed to check verification status."
        }
    }

    func resendVerification() async {
        Log.vm.info("VerifyEmailViewModel.resendVerification: user action")
        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }
        do {
            try await authRepo.sendEmailVerification()
            Log.vm.info("VerifyEmailViewModel.resendVerification: success")
            successMessage = "Verification email sent. Check your inbox."
        } catch {
            Log.vm.error("VerifyEmailViewModel.resendVerification: failed — \(error)")
            errorMessage = "Failed to send verification email."
        }
    }
}
