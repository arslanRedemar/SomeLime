//
//  UserSignUpFailures.swift
//  Somlimee
//
//  Created by Chanhee on 2023/04/01.
//

import Foundation

enum UserSignUpFailures: Error{
    case CouldNotSendVerificationEmail
    case UserDoesNotExist
    case UserAlreadyVerified
    case CouldNotCreatUser
}
