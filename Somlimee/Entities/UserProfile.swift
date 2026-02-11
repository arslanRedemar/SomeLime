//
//  UserData.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/07.
//

import UIKit

struct UserProfile {
    let isLoggedIn: Bool
    var userLimeTestResult: LimeTestReport
    var userCurrentPosts: [LimeRoomPostMeta]
    var userCurrentComments: [LimeRoomPostComment]
    var userName: String
    var userID: String
    var userSignedDate: String
    var userPoints: Int
    var numOfPosts: Int
    var numOfReceivedVotes: Int
    var numOfGivenVotes: Int
    var numOfActiveDays: Int
}
