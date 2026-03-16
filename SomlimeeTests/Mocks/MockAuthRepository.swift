@testable import Somlimee
import Foundation

final class MockAuthRepository: AuthRepository {
    // MARK: - Properties
    var isLoggedIn: Bool = false
    var currentUserID: String?
    var currentUserEmail: String?
    var isEmailVerified: Bool = false

    // MARK: - Call counts
    var signInCallCount = 0
    var signOutCallCount = 0
    var addAuthStateListenerCallCount = 0
    var createUserCallCount = 0
    var sendEmailVerificationCallCount = 0
    var reloadCurrentUserCallCount = 0
    var sendPasswordResetCallCount = 0
    var updatePasswordCallCount = 0
    var deleteAccountCallCount = 0
    var reauthenticateCallCount = 0

    // MARK: - Captured arguments
    var lastSignInEmail: String?
    var lastSignInPassword: String?
    var lastPasswordResetEmail: String?
    var lastNewPassword: String?
    var lastReauthEmail: String?
    var lastReauthPassword: String?

    // MARK: - Stubbed errors
    var signInError: Error?
    var signOutError: Error?
    var createUserError: Error?
    var sendEmailVerificationError: Error?
    var reloadCurrentUserError: Error?
    var sendPasswordResetError: Error?
    var updatePasswordError: Error?
    var deleteAccountError: Error?
    var reauthenticateError: Error?

    // MARK: - AuthRepository conformance

    func signIn(email: String, password: String) async throws {
        signInCallCount += 1
        lastSignInEmail = email
        lastSignInPassword = password
        if let error = signInError { throw error }
    }

    func signOut() throws {
        signOutCallCount += 1
        if let error = signOutError { throw error }
    }

    func addAuthStateListener(_ handler: @escaping (String?) -> Void) {
        addAuthStateListenerCallCount += 1
        handler(currentUserID)
    }

    func createUser(email: String, password: String) async throws {
        createUserCallCount += 1
        if let error = createUserError { throw error }
    }

    func sendEmailVerification() async throws {
        sendEmailVerificationCallCount += 1
        if let error = sendEmailVerificationError { throw error }
    }

    func reloadCurrentUser() async throws {
        reloadCurrentUserCallCount += 1
        if let error = reloadCurrentUserError { throw error }
    }

    func sendPasswordReset(email: String) async throws {
        sendPasswordResetCallCount += 1
        lastPasswordResetEmail = email
        if let error = sendPasswordResetError { throw error }
    }

    func updatePassword(newPassword: String) async throws {
        updatePasswordCallCount += 1
        lastNewPassword = newPassword
        if let error = updatePasswordError { throw error }
    }

    func deleteAccount() async throws {
        deleteAccountCallCount += 1
        if let error = deleteAccountError { throw error }
    }

    func reauthenticate(email: String, password: String) async throws {
        reauthenticateCallCount += 1
        lastReauthEmail = email
        lastReauthPassword = password
        if let error = reauthenticateError { throw error }
    }
}
