//
//  RemoteDataSource.swift
//  Somlimee
//
//  Created by Chanhee on 2024/01/24.
//

import Foundation

protocol RemoteDataSource {
    func updateUser(userInfo: [String: Any]) async throws -> Void
    
    func getLimeTrendsData() async throws -> [String : Any]?
    
    func getUserData() async throws -> [String: Any]?
    
    func isUserLoggedIn() async throws -> Bool
    
    func getQuestions() async throws -> [String : Any]?
    
    func getBoardInfoData(boardName: String) async throws -> [String : Any]?
    
    func getBoardPostMetaList(boardName: String, startTime: String?, counts: Int) async throws -> [[String : Any]]?

    func getBoardHotPostsList(boardName: String, startTime: String?, counts: Int) async throws -> [String]?
    
    func getBoardPostMeta(boardName: String, postId: String) async throws -> [String : Any]?
    
    func getBoardPostContent(boardName: String, postId: String) async throws -> [[String : Any]]?
    
    func createPost(boardName: String, postData: BoardPostContentData) async throws -> Void
    
    func writeComment(boardName: String, postId: String, target: String ,text: String) async throws -> Void

    func getComments(boardName: String, postId: String) async throws -> [[String: Any]]?

    func uploadImage(data: Data, path: String) async throws -> String

    func deleteUser() async throws

    func voteUpPost(boardName: String, postId: String) async throws

    func createReport(boardName: String, postId: String, reason: String, detail: String) async throws

    func getUserPosts(userId: String) async throws -> [[String: Any]]?

    func getUserComments(userId: String) async throws -> [[String: Any]]?

    func getNotifications(limit: Int) async throws -> [[String: Any]]?

    func markNotificationRead(notificationId: String) async throws
}
