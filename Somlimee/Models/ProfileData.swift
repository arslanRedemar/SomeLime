//
//  ProfileData.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/28.
//

import Foundation

struct ProfileData: Codable {
    let userName: String
    let profileImageURL: String?
    let totalUps: Int
    let signUpDate: String
    let numOfPosts: Int
    let receivedUps: Int
    let points: Int
    let daysOfActive: Int
    let badges: [String]
    let personalityTestResult: PersonalityTestResultData
    let personalityType: String

    enum CodingKeys: String, CodingKey {
        case userName = "UserName"
        case profileImageURL
        case totalUps = "TotalUps"
        case signUpDate = "SignUpDate"
        case numOfPosts = "NumOfPosts"
        case receivedUps = "ReceivedUps"
        case points = "Points"
        case daysOfActive = "DaysOfActive"
        case badges
        case personalityTestResult = "PersonalityTestResult"
        case personalityType = "PersonalityType"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userName = try container.decode(String.self, forKey: .userName)
        profileImageURL = try container.decodeIfPresent(String.self, forKey: .profileImageURL)
        totalUps = try container.decodeIfPresent(Int.self, forKey: .totalUps) ?? 0
        signUpDate = try container.decode(String.self, forKey: .signUpDate)
        numOfPosts = try container.decode(Int.self, forKey: .numOfPosts)
        receivedUps = try container.decode(Int.self, forKey: .receivedUps)
        points = try container.decode(Int.self, forKey: .points)
        daysOfActive = try container.decode(Int.self, forKey: .daysOfActive)
        badges = try container.decodeIfPresent([String].self, forKey: .badges) ?? []
        personalityType = try container.decode(String.self, forKey: .personalityType)
        // Firestore stores PersonalityTestResult as [Int] with 4 elements
        let scores = try container.decode([Int].self, forKey: .personalityTestResult)
        personalityTestResult = PersonalityTestResultData(
            Strenuousness: scores.count > 0 ? scores[0] : 0,
            Receptiveness: scores.count > 1 ? scores[1] : 0,
            Harmonization: scores.count > 2 ? scores[2] : 0,
            Coagulation: scores.count > 3 ? scores[3] : 0,
            type: personalityType
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userName, forKey: .userName)
        try container.encodeIfPresent(profileImageURL, forKey: .profileImageURL)
        try container.encode(totalUps, forKey: .totalUps)
        try container.encode(signUpDate, forKey: .signUpDate)
        try container.encode(numOfPosts, forKey: .numOfPosts)
        try container.encode(receivedUps, forKey: .receivedUps)
        try container.encode(points, forKey: .points)
        try container.encode(daysOfActive, forKey: .daysOfActive)
        try container.encode(badges, forKey: .badges)
        try container.encode(personalityType, forKey: .personalityType)
        try container.encode([
            personalityTestResult.Strenuousness,
            personalityTestResult.Receptiveness,
            personalityTestResult.Harmonization,
            personalityTestResult.Coagulation
        ], forKey: .personalityTestResult)
    }

    init(userName: String, profileImageURL: String?, totalUps: Int, signUpDate: String, numOfPosts: Int, receivedUps: Int, points: Int, daysOfActive: Int, badges: [String], personalityTestResult: PersonalityTestResultData, personalityType: String) {
        self.userName = userName
        self.profileImageURL = profileImageURL
        self.totalUps = totalUps
        self.signUpDate = signUpDate
        self.numOfPosts = numOfPosts
        self.receivedUps = receivedUps
        self.points = points
        self.daysOfActive = daysOfActive
        self.badges = badges
        self.personalityTestResult = personalityTestResult
        self.personalityType = personalityType
    }
}
