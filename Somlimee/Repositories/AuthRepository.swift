//
//  AuthRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/07.
//

import Foundation

protocol AuthRepository {
    var isLoggedIn: Bool { get }
    var currentUserID: String? { get }
    var currentUserEmail: String? { get }
    var isEmailVerified: Bool { get }
    func signIn(email: String, password: String) async throws
    func signOut() throws
    func addAuthStateListener(_ handler: @escaping (String?) -> Void)
    func createUser(email: String, password: String) async throws
    func sendEmailVerification() async throws
    func reloadCurrentUser() async throws
    func sendPasswordReset(email: String) async throws
    func updatePassword(newPassword: String) async throws
    func deleteAccount() async throws
    func reauthenticate(email: String, password: String) async throws
}
