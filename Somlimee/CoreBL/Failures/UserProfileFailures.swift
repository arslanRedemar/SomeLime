//
//  UserProfileFailures.swift
//  Somlimee
//

import Foundation

enum UserProfileFailures: Error {
    case updateNicknameFailed
    case deleteAccountFailed
    case reauthenticationRequired
}
