//
//  FirebaseAuthRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/07.
//

import Foundation
import FirebaseAuth
import os

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
        Log.auth.info("signIn: email=\(email)")
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            Log.auth.info("signIn: success")
        } catch {
            Log.auth.error("signIn: failed — \(error.localizedDescription)")
            throw UserLoginFailures.LoginFailed
        }
    }

    func signOut() throws {
        Log.auth.info("signOut: start")
        do {
            try Auth.auth().signOut()
            Log.auth.info("signOut: success")
        } catch {
            Log.auth.error("signOut: failed — \(error.localizedDescription)")
            throw UserLoginFailures.LogOutFailed
        }
    }

    func addAuthStateListener(_ handler: @escaping (String?) -> Void) {
        Log.auth.debug("addAuthStateListener: registered")
        Auth.auth().addStateDidChangeListener { _, user in
            Log.auth.debug("authStateChanged: uid=\(user?.uid ?? "nil")")
            handler(user?.uid)
        }
    }

    func createUser(email: String, password: String) async throws {
        Log.auth.info("createUser: email=\(email)")
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            Log.auth.info("createUser: success")
        } catch {
            Log.auth.error("createUser: failed — \(error.localizedDescription)")
            throw UserSignUpFailures.CouldNotCreatUser
        }
    }

    func sendEmailVerification() async throws {
        Log.auth.info("sendEmailVerification: start")
        guard let user = Auth.auth().currentUser else {
            Log.auth.error("sendEmailVerification: no current user")
            throw UserSignUpFailures.UserDoesNotExist
        }
        if user.isEmailVerified {
            Log.auth.info("sendEmailVerification: already verified")
            throw UserSignUpFailures.UserAlreadyVerified
        }
        do {
            try await user.sendEmailVerification()
            Log.auth.info("sendEmailVerification: sent")
        } catch {
            Log.auth.error("sendEmailVerification: failed — \(error.localizedDescription)")
            throw UserSignUpFailures.CouldNotSendVerificationEmail
        }
    }

    func reloadCurrentUser() async throws {
        Log.auth.debug("reloadCurrentUser: start")
        try await Auth.auth().currentUser?.reload()
    }

    func sendPasswordReset(email: String) async throws {
        Log.auth.info("sendPasswordReset: email=\(email)")
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            Log.auth.info("sendPasswordReset: sent")
        } catch {
            Log.auth.error("sendPasswordReset: failed — \(error.localizedDescription)")
            throw PasswordResetFailures.sendResetEmailFailed
        }
    }

    func updatePassword(newPassword: String) async throws {
        Log.auth.info("updatePassword: start")
        guard let user = Auth.auth().currentUser else {
            Log.auth.error("updatePassword: no current user")
            throw UserLoginFailures.LoginFailed
        }
        do {
            try await user.updatePassword(to: newPassword)
            Log.auth.info("updatePassword: success")
        } catch let error as NSError {
            Log.auth.error("updatePassword: failed — \(error.localizedDescription)")
            if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                throw UserProfileFailures.reauthenticationRequired
            }
            throw PasswordResetFailures.updatePasswordFailed
        }
    }

    func deleteAccount() async throws {
        Log.auth.info("deleteAccount: start")
        guard let user = Auth.auth().currentUser else {
            Log.auth.error("deleteAccount: no current user")
            throw UserLoginFailures.LoginFailed
        }
        do {
            try await user.delete()
            Log.auth.info("deleteAccount: success")
        } catch let error as NSError {
            Log.auth.error("deleteAccount: failed — \(error.localizedDescription)")
            if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                throw UserProfileFailures.reauthenticationRequired
            }
            throw UserProfileFailures.deleteAccountFailed
        }
    }

    func reauthenticate(email: String, password: String) async throws {
        Log.auth.info("reauthenticate: email=\(email)")
        guard let user = Auth.auth().currentUser else {
            Log.auth.error("reauthenticate: no current user")
            throw UserLoginFailures.LoginFailed
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            try await user.reauthenticate(with: credential)
            Log.auth.info("reauthenticate: success")
        } catch {
            Log.auth.error("reauthenticate: failed — \(error.localizedDescription)")
            throw UserProfileFailures.reauthenticationRequired
        }
    }
}
