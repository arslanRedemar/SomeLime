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
}
