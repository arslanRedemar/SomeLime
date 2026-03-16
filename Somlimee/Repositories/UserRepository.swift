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
        Log.repo.debug("[UserRepositoryImpl.isUserLoggedIn] Checking user login status")
        do {
            let result = try await dataSource.isUserLoggedIn()
            Log.repo.debug("[UserRepositoryImpl.isUserLoggedIn] User logged in: \(result)")
            return result
        } catch {
            Log.repo.error("[UserRepositoryImpl.isUserLoggedIn] Failed — \(error.localizedDescription)")
            throw error
        }
    }

    func getUserData() async throws -> ProfileData? {
        Log.repo.debug("[UserRepositoryImpl.getUserData] Fetching user profile data")
        do {
            guard let data = try await dataSource.getUserData() else {
                Log.repo.debug("[UserRepositoryImpl.getUserData] No user data found")
                return nil
            }
            let profile = try DictionaryDecoder.decode(ProfileData.self, from: data)
            Log.repo.debug("[UserRepositoryImpl.getUserData] Successfully fetched user profile")
            return profile
        } catch {
            Log.repo.error("[UserRepositoryImpl.getUserData] Failed — \(error.localizedDescription)")
            throw error
        }
    }

    func updateNickname(_ nickname: String) async throws {
        Log.repo.info("[UserRepositoryImpl.updateNickname] Updating nickname to \(nickname)")
        do {
            try await dataSource.updateUser(userInfo: ["UserName": nickname])
            Log.repo.info("[UserRepositoryImpl.updateNickname] Successfully updated nickname")
        } catch {
            Log.repo.error("[UserRepositoryImpl.updateNickname] Failed — \(error.localizedDescription)")
            throw error
        }
    }

    func deleteUserData() async throws {
        Log.repo.info("[UserRepositoryImpl.deleteUserData] Deleting user data")
        do {
            try await dataSource.deleteUser()
            Log.repo.info("[UserRepositoryImpl.deleteUserData] Successfully deleted user data")
        } catch {
            Log.repo.error("[UserRepositoryImpl.deleteUserData] Failed — \(error.localizedDescription)")
            throw error
        }
    }

    func getUserPosts(userId: String) async throws -> [BoardPostMetaData] {
        Log.repo.debug("[UserRepositoryImpl.getUserPosts] Fetching posts for userId=\(userId)")
        do {
            guard let dataList = try await dataSource.getUserPosts(userId: userId) else {
                Log.repo.debug("[UserRepositoryImpl.getUserPosts] No posts found for userId=\(userId)")
                return []
            }
            let result = dataList.compactMap { data in
                var meta = try? DictionaryDecoder.decode(BoardPostMetaData.self, from: data)
                meta?.boardID = (data["BoardName"] as? String) ?? ""
                return meta
            }
            Log.repo.debug("[UserRepositoryImpl.getUserPosts] Successfully fetched \(result.count) posts for userId=\(userId)")
            return result
        } catch {
            Log.repo.error("[UserRepositoryImpl.getUserPosts] Failed for userId=\(userId) — \(error.localizedDescription)")
            throw error
        }
    }

    func getUserComments(userId: String) async throws -> [BoardPostCommentData] {
        Log.repo.debug("[UserRepositoryImpl.getUserComments] Fetching comments for userId=\(userId)")
        do {
            guard let dataList = try await dataSource.getUserComments(userId: userId) else {
                Log.repo.debug("[UserRepositoryImpl.getUserComments] No comments found for userId=\(userId)")
                return []
            }
            let result = dataList.compactMap { try? DictionaryDecoder.decode(BoardPostCommentData.self, from: $0) }
            Log.repo.debug("[UserRepositoryImpl.getUserComments] Successfully fetched \(result.count) comments for userId=\(userId)")
            return result
        } catch {
            Log.repo.error("[UserRepositoryImpl.getUserComments] Failed for userId=\(userId) — \(error.localizedDescription)")
            throw error
        }
    }

    func createInitialProfile(email: String) async throws {
        Log.repo.info("[UserRepositoryImpl.createInitialProfile] Creating initial profile for email=\(email)")
        do {
            let userName = email.components(separatedBy: "@").first ?? email
            try await dataSource.updateUser(userInfo: [
                "UserName": userName,
                "SignUpDate": Date().description,
                "Points": 0,
                "NumOfPosts": 0,
                "ReceivedUps": 0,
                "TotalUps": 0,
                "DaysOfActive": 0,
                "PersonalityTestResult": [0, 0, 0, 0],
                "PersonalityType": ""
            ])
            Log.repo.info("[UserRepositoryImpl.createInitialProfile] Successfully created initial profile")
        } catch {
            Log.repo.error("[UserRepositoryImpl.createInitialProfile] Failed for email=\(email) — \(error.localizedDescription)")
            throw error
        }
    }
}
