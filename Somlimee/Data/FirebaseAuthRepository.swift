//
//  FirebaseAuthRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/07.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthRepository: AuthRepository {

    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }

    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    var currentUserEmail: String? {
        Auth.auth().currentUser?.email
    }

    var isEmailVerified: Bool {
        Auth.auth().currentUser?.isEmailVerified ?? false
    }

    func signIn(email: String, password: String) async throws {
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            throw UserLoginFailures.LoginFailed
        }
    }

    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            throw UserLoginFailures.LogOutFailed
        }
    }

    func addAuthStateListener(_ handler: @escaping (String?) -> Void) {
        Auth.auth().addStateDidChangeListener { _, user in
            handler(user?.uid)
        }
    }

    func createUser(email: String, password: String) async throws {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
        } catch {
            throw UserSignUpFailures.CouldNotCreatUser
        }
    }

    func sendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser else {
            throw UserSignUpFailures.UserDoesNotExist
        }
        if user.isEmailVerified {
            throw UserSignUpFailures.UserAlreadyVerified
        }
        do {
            try await user.sendEmailVerification()
        } catch {
            throw UserSignUpFailures.CouldNotSendVerificationEmail
        }
    }

    func reloadCurrentUser() async throws {
        try await Auth.auth().currentUser?.reload()
    }

    func sendPasswordReset(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw PasswordResetFailures.sendResetEmailFailed
        }
    }

    func updatePassword(newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw UserLoginFailures.LoginFailed
        }
        do {
            try await user.updatePassword(to: newPassword)
        } catch let error as NSError {
            if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                throw UserProfileFailures.reauthenticationRequired
            }
            throw PasswordResetFailures.updatePasswordFailed
        }
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw UserLoginFailures.LoginFailed
        }
        do {
            try await user.delete()
        } catch let error as NSError {
            if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                throw UserProfileFailures.reauthenticationRequired
            }
            throw UserProfileFailures.deleteAccountFailed
        }
    }

    func reauthenticate(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw UserLoginFailures.LoginFailed
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            try await user.reauthenticate(with: credential)
        } catch {
            throw UserProfileFailures.reauthenticationRequired
        }
    }
}
