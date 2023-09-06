//
//  ProfileViewRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2023/05/22.
//

import Foundation

protocol ProfileViewRepository {
    func getUserData(uid: String) async throws -> ProfileData?
}

class ProfileViewRepositoryImpl: ProfileViewRepository{
    func getUserData(uid: String) async throws -> ProfileData? {
        let data = try await DataSourceService.sharedInstance.getUserData(uid: uid)
        guard let userName: String = data?["UserName"] as? String else{
            throw DataSourceFailures.CouldNotFindDocument
        }
        guard let totalUps: Int = data?["TotalUps"] as? Int else{
            throw DataSourceFailures.CouldNotFindDocument
        }
        
        guard let receivedUps: Int = data?["ReceivedUps"] as? Int else{
            throw DataSourceFailures.CouldNotFindDocument
        }
        
        guard let points: Int = data?["Points"] as? Int else{
            throw DataSourceFailures.CouldNotFindDocument
        }
        
        guard let daysOfActive: Int = data?["DaysOfActive"] as? Int else{
            throw DataSourceFailures.CouldNotFindDocument
        }
        guard let personalityType: String = data?["PersonalityType"] as? String else{
            throw DataSourceFailures.CouldNotFindDocument
        }
        guard let personalityTestResult: [Int] = data?["PersonalityTestResult"] as? [Int] else{
                throw DataSourceFailures.CouldNotFindDocument
        }
        guard let numOfPosts: Int = data?["NumOfPosts"] as? Int else{
            throw DataSourceFailures.CouldNotFindDocument
        }
        guard let signUpDate: String = data?["SignUpDate"] as? String else{
            throw DataSourceFailures.CouldNotFindDocument
        }
//        guard let recentPostList: [String: Any] = data?["RecentPosts"] as? [String: Any] else{
//                throw DataSourceFailures.CouldNotFindDocument
        return ProfileData(userName: userName, profileImage: nil, totalUps: totalUps, signUpDate: signUpDate, numOfPosts: numOfPosts, receivedUps: receivedUps, points: points, daysOfActive: daysOfActive, badges: [], personalityTestResult: PersonalityTestResultData(Strenuousness: personalityTestResult[0], Receptiveness: personalityTestResult[1], Harmonization: personalityTestResult[2], Coagulation: personalityTestResult[3], type: personalityType), personalityType: personalityType)
    }
}
