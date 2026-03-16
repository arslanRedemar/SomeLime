//
//  Route.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/07.
//

import Foundation

enum Route: Hashable {
    case home
    case limeRoom(boardName: String)
    case boardPost(boardName: String, postId: String)
    case boardPostWrite(boardName: String)
    case search
    case personalityTest
    case personalityTestResult
    case login
    case signUp
    case verifyEmail
    case psyTestList
    case userCurrentPosts
    case userCurrentComments
    case appSettings
    case profileSettings
    case forgotPassword
    case changePassword
    case trendSearchResult(keyword: String)
    case report(boardName: String, postId: String)
    case notifications
}
