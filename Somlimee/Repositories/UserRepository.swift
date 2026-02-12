//
//  UserRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/01/25.
//

import Foundation

protocol UserRepository {
    func getUserData() async throws -> ProfileData?
    func isUserLoggedIn() async throws -> Bool
    func updateNickname(_ nickname: String) async throws
    func deleteUserData() async throws
    func getUserPosts(userId: String) async throws -> [BoardPostMetaData]
    func getUserComments(userId: String) async throws -> [BoardPostCommentData]
    func createInitialProfile(email: String) async throws
}

class UserRepositoryImpl: UserRepository {
    private let dataSource: DataSource

    init(dataSource: DataSource){
        self.dataSource = dataSource
    }

    func isUserLoggedIn() async throws -> Bool {
        return try await dataSource.isUserLoggedIn()
    }

    func getUserData() async throws -> ProfileData? {
        guard let data = try await dataSource.getUserData() else { return nil }
        return try DictionaryDecoder.decode(ProfileData.self, from: data)
    }

    func updateNickname(_ nickname: String) async throws {
        try await dataSource.updateUser(userInfo: ["UserName": nickname])
    }

    func deleteUserData() async throws {
        try await dataSource.deleteUser()
    }

    func getUserPosts(userId: String) async throws -> [BoardPostMetaData] {
        guard let dataList = try await dataSource.getUserPosts(userId: userId) else {
            return []
        }
        return dataList.compactMap { data in
            var meta = try? DictionaryDecoder.decode(BoardPostMetaData.self, from: data)
            meta?.boardID = (data["BoardName"] as? String) ?? ""
            return meta
        }
    }

    func getUserComments(userId: String) async throws -> [BoardPostCommentData] {
        guard let dataList = try await dataSource.getUserComments(userId: userId) else {
            return []
        }
        return dataList.compactMap { try? DictionaryDecoder.decode(BoardPostCommentData.self, from: $0) }
    }

    func createInitialProfile(email: String) async throws {
        let userName = email.components(separatedBy: "@").first ?? email
        try await dataSource.updateUser(userInfo: [
            "UserName": userName,
            "SignUpDate": Date().description,
            "Points": 0,
            "NumOfPosts": 0,
            "ReceivedUps": 0,
            "DaysOfActive": 0,
            "PersonalityTestResult": [0, 0, 0, 0],
            "PersonalityType": ""
        ])
    }
}
