//
//  CacheControlService.swift
//  Somlimee
//
//  Created by Chanhee on 2023/03/28.
//

import Foundation

final class FirebaseSQLiteDataSource: DataSource{

    private let remoteDataSource: RemoteDataSource
    private let localDataSource: LocalDataSource

    init(remote: RemoteDataSource, local: LocalDataSource) {
        self.remoteDataSource = remote
        self.localDataSource = local
    }

    //MARK: - SIGN UP

    func updateUser(userInfo: [String: Any]) async throws -> Void {
        try await remoteDataSource.updateUser(userInfo: userInfo)
    }

    func isUserLoggedIn() async throws -> Bool {
        return try await remoteDataSource.isUserLoggedIn()
    }

    //MARK: - HOME VIEW REPOSITORY

    func getLimeTrendsData() async throws -> [String : Any]? {
        return try await remoteDataSource.getLimeTrendsData()
    }

    func getCategoryData() async throws -> [String : Any]?{
        return try await localDataSource.getCategoryData()
    }

    func getBoardListData() async throws -> [String: Any]?{
        return try await localDataSource.getBoardListData()
    }

    //MARK: - PROFILE VIEW REPOSITORY

    func getUserData() async throws -> [String: Any]?{
        return try await remoteDataSource.getUserData()
    }

    //MARK: - PERSONALITY TEST VIEW REPOSITORY

    func getQuestions() async throws -> [String : Any]?{
        return try await remoteDataSource.getQuestions()
    }

    //MARK: - Board View Repository

    func getBoardInfoData(boardName: String) async throws -> [String : Any]?{
        return try await remoteDataSource.getBoardInfoData(boardName: boardName)
    }

    func getBoardPostMetaList(boardName: String, startTime: String?, counts: Int) async throws -> [[String : Any]]?{
        return try await remoteDataSource.getBoardPostMetaList(boardName: boardName, startTime: startTime, counts: counts)
    }

    func getBoardHotPostsList(boardName: String, startTime: String?, counts: Int) async throws -> [String]?{
        return try await remoteDataSource.getBoardHotPostsList(boardName: boardName, startTime: startTime, counts: counts)
    }

    func getBoardPostMeta(boardName: String, postId: String) async throws -> [String : Any]? {
        return try await remoteDataSource.getBoardPostMeta(boardName: boardName, postId: postId)
    }

    func getBoardPostContent(boardName: String, postId: String) async throws -> [[String : Any]]?{
        return try await remoteDataSource.getBoardPostContent(boardName: boardName, postId: postId)
    }

    func createPost(boardName: String, postData: BoardPostContentData) async throws -> Void{
        try await remoteDataSource.createPost(boardName: boardName, postData: postData)
    }

    func writeComment(boardName: String, postId: String, target: String, text: String) async throws -> Void {
        try await remoteDataSource.writeComment(boardName: boardName, postId: postId, target: target, text: text)
    }

    func getComments(boardName: String, postId: String) async throws -> [[String: Any]]? {
        return try await remoteDataSource.getComments(boardName: boardName, postId: postId)
    }

    //MARK: - AppStates

    func updateAppStates(appStates: AppStatesData) async throws -> Void{
        try await localDataSource.updateAppStates(appStates: appStates)
    }

    func getAppState() async throws -> [String : Any]?{
        return try await localDataSource.getAppState()
    }

    func appStatesInit() async throws {
        return try await localDataSource.appStatesInit()
    }

    func uploadImage(data: Data, path: String) async throws -> String {
        return try await remoteDataSource.uploadImage(data: data, path: path)
    }

    func deleteUser() async throws {
        try await remoteDataSource.deleteUser()
    }

    func voteUpPost(boardName: String, postId: String) async throws {
        try await remoteDataSource.voteUpPost(boardName: boardName, postId: postId)
    }

    func createReport(boardName: String, postId: String, reason: String, detail: String) async throws {
        try await remoteDataSource.createReport(boardName: boardName, postId: postId, reason: reason, detail: detail)
    }

    func getUserPosts(userId: String) async throws -> [[String: Any]]? {
        return try await remoteDataSource.getUserPosts(userId: userId)
    }

    func getUserComments(userId: String) async throws -> [[String: Any]]? {
        return try await remoteDataSource.getUserComments(userId: userId)
    }

    func getNotifications(limit: Int) async throws -> [[String: Any]]? {
        return try await remoteDataSource.getNotifications(limit: limit)
    }

    func markNotificationRead(notificationId: String) async throws {
        try await remoteDataSource.markNotificationRead(notificationId: notificationId)
    }
}
