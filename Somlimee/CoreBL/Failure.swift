//
//  Failure.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/31.
//

import Foundation

enum UserSignUpFailures: Error, Equatable{
    case LocalDataSourceFailure
    case RemoteDataSourceFailure
    case CacheControlServiceFailure
    case UserLoginServiceFailure
    case UserSignUpWithEmailServiceFailure
    
}
