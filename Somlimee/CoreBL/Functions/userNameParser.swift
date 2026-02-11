//
//  translateUserToName.swift
//  Somlimee
//
//  Created by Chanhee on 2023/05/17.
//

import Foundation
import Firebase

func userNameParser(uid: String) async throws -> String? {
    // Simply Converts UID to UserName
    guard let db = FirebaseDataSource.sharedInstance.database else {
        throw DataSourceFailures.CouldNotFindRemoteDataBase
    }
    guard uid != "" else{
        return "ERROR"
    }
    guard let data = try await db.collection("Users").document(uid).getDocument().data() else{
        throw DataSourceFailures.CouldNotFindDocument
    }
    return data["UserName"] as? String
}
