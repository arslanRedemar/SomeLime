//
//  ProfileData.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/28.
//

import UIKit

struct ProfileData {
    let userName: String
    let profileImage: UIImage?  
    let totalUps: Int
    let signUpDate: String
    let numOfPosts: Int
    let receivedUps: Int
    let points: Int
    let daysOfActive: Int
    let badges: [String]
    let personalityTestResult: PersonalityTestResultData
    let personalityType: String
}
