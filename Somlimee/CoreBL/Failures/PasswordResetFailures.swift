//
//  PasswordResetFailures.swift
//  Somlimee
//

import Foundation

enum PasswordResetFailures: Error {
    case sendResetEmailFailed
    case updatePasswordFailed
}
