//
//  UserSignUpWithEmailService.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/31.
//

import Foundation
import Firebase


final class UserCreateFunctions{
    static let sharedInstance = UserCreateFunctions()
    internal func createUser(Email: String, PW: String, userInfo: ProfileData) async throws -> Void{
        do{
            try await FirebaseAuth.Auth.auth().createUser(withEmail: Email, password: PW)
            print(userInfo.signUpDate)
            try await FirebaseSQLiteDataSource.sharedInstance.updateUser(userInfo: [
                "UserName": userInfo.userName,
                "ProfileImageURL": "", //Later Modify
                "TotalUps": userInfo.totalUps,
                "SignUpDate": userInfo.signUpDate,
                "NumOfPosts": userInfo.numOfPosts,
                "ReceivedUps": userInfo.receivedUps,
                "Points": userInfo.points,
                "DaysOfActive": userInfo.daysOfActive,
                "Badges": userInfo.badges,
                "PersonalityTestResult": [
                    userInfo.personalityTestResult.Strenuousness,
                    userInfo.personalityTestResult.Receptiveness,
                    userInfo.personalityTestResult.Harmonization,
                    userInfo.personalityTestResult.Coagulation
                ],
                "PersonalityType": userInfo.personalityTestResult.type
            ])
        }catch{
            print("CouldNotCreatUser")
            throw UserSignUpFailures.CouldNotCreatUser
        }
    }
    internal func verifyEmail() async throws -> Void{
        
        guard let user = FirebaseAuth.Auth.auth().currentUser else{
            print("UserDoesNotExist")
            throw UserSignUpFailures.UserDoesNotExist
        }
        if user.isEmailVerified {
            print("UserAlreadyVerifiedError")
            throw UserSignUpFailures.UserAlreadyVerified
        }
        
        do{
            try await user.sendEmailVerification()
        }catch{
            print("CouldNotSendVerificationEmail\(error)")
            throw UserSignUpFailures.CouldNotSendVerificationEmail
        }
    }
    
}
