//
//  PostRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/01/25.
//

import Foundation

protocol PostRepository {
    func writeBoardPost(boardName: String, postData: BoardPostContentData) async throws -> Void
    func getBoardPostMeta(boardName: String, postId: String) async throws -> BoardPostMetaData?
    func getBoardPostContent(boardName: String, postId: String) async throws -> BoardPostContentData?
    func getComments(boardName: String, postId: String) async throws -> [BoardPostCommentData]
    func writeComment(boardName: String, postId: String, target: String, text: String) async throws
    func voteUpPost(boardName: String, postId: String) async throws
    func uploadImage(data: Data, path: String) async throws -> String
}

class PostRepositoryImpl: PostRepository{
    private let dataSource: DataSource

    init(dataSource: DataSource){
        self.dataSource = dataSource
    }

    func writeBoardPost(boardName: String, postData: BoardPostContentData) async throws -> Void {
        Log.repo.info("[PostRepositoryImpl.writeBoardPost] Writing post to board=\(boardName) title=\(postData.boardPostTitle)")
        do{
            try await dataSource.createPost(boardName: boardName, postData: postData)
            Log.repo.info("[PostRepositoryImpl.writeBoardPost] Successfully wrote post to board=\(boardName)")
        }catch{
            Log.repo.error("[PostRepositoryImpl.writeBoardPost] Failed for board=\(boardName) — \(error.localizedDescription)")
            throw DataSourceFailures.CouldNotWritePost
        }
    }

    func getBoardPostMeta(boardName: String, postId: String) async throws -> BoardPostMetaData? {
        Log.repo.debug("[PostRepositoryImpl.getBoardPostMeta] Fetching post meta for board=\(boardName) postId=\(postId)")
        do {
            guard let data = try await dataSource.getBoardPostMeta(boardName: boardName, postId: postId) else {
                Log.repo.debug("[PostRepositoryImpl.getBoardPostMeta] No post meta found for postId=\(postId)")
                return nil
            }
            var meta = try DictionaryDecoder.decode(BoardPostMetaData.self, from: data)
            meta.boardID = boardName
            Log.repo.debug("[PostRepositoryImpl.getBoardPostMeta] Successfully fetched post meta for postId=\(postId)")
            return meta
        } catch {
            Log.repo.error("[PostRepositoryImpl.getBoardPostMeta] Failed for board=\(boardName) postId=\(postId) — \(error.localizedDescription)")
            throw error
        }
    }

    func getBoardPostContent(boardName: String, postId: String) async throws -> BoardPostContentData? {
        Log.repo.debug("[PostRepositoryImpl.getBoardPostContent] Fetching post content for board=\(boardName) postId=\(postId)")
        do {
            guard let data = try await dataSource.getBoardPostContent(boardName: boardName, postId: postId) else {
                Log.repo.debug("[PostRepositoryImpl.getBoardPostContent] No post content found for postId=\(postId)")
                return nil
            }
            guard let meta = try await dataSource.getBoardPostMeta(boardName: boardName, postId: postId) else {
                Log.repo.debug("[PostRepositoryImpl.getBoardPostContent] No post meta found for postId=\(postId)")
                return nil
            }
            let boardPostTap = (meta["BoardTap"] as? String) ?? ""
            let boardPostUserId = (meta["UserId"] as? String) ?? ""
            let boardPostTitle = (meta["PostTitle"] as? String) ?? ""
            let boardPostParagraph = (data[0]["Text"] as? String) ?? ""
            Log.repo.debug("[PostRepositoryImpl.getBoardPostContent] Successfully fetched post content for postId=\(postId)")
            return BoardPostContentData(boardPostTap: boardPostTap, boardPostUserId: boardPostUserId, boardPostTitle: boardPostTitle, boardPostParagraph: boardPostParagraph, boardPostImageURLs: [], boardPostComments: [])
        } catch {
            Log.repo.error("[PostRepositoryImpl.getBoardPostContent] Failed for board=\(boardName) postId=\(postId) — \(error.localizedDescription)")
            throw error
        }
    }

    func getComments(boardName: String, postId: String) async throws -> [BoardPostCommentData] {
        Log.repo.debug("[PostRepositoryImpl.getComments] Fetching comments for board=\(boardName) postId=\(postId)")
        do {
            guard let data = try await dataSource.getComments(boardName: boardName, postId: postId) else {
                Log.repo.debug("[PostRepositoryImpl.getComments] No comments found for postId=\(postId)")
                return []
            }
            let result = data.compactMap { try? DictionaryDecoder.decode(BoardPostCommentData.self, from: $0) }
            Log.repo.debug("[PostRepositoryImpl.getComments] Successfully fetched \(result.count) comments for postId=\(postId)")
            return result
        } catch {
            Log.repo.error("[PostRepositoryImpl.getComments] Failed for board=\(boardName) postId=\(postId) — \(error.localizedDescription)")
            throw error
        }
    }

    func writeComment(boardName: String, postId: String, target: String, text: String) async throws {
        Log.repo.info("[PostRepositoryImpl.writeComment] Writing comment to board=\(boardName) postId=\(postId) target=\(target)")
        do {
            try await dataSource.writeComment(boardName: boardName, postId: postId, target: target, text: text)
            Log.repo.info("[PostRepositoryImpl.writeComment] Successfully wrote comment to postId=\(postId)")
        } catch {
            Log.repo.error("[PostRepositoryImpl.writeComment] Failed for board=\(boardName) postId=\(postId) — \(error.localizedDescription)")
            throw error
        }
    }

    func voteUpPost(boardName: String, postId: String) async throws {
        Log.repo.info("[PostRepositoryImpl.voteUpPost] Voting up post board=\(boardName) postId=\(postId)")
        do {
            try await dataSource.voteUpPost(boardName: boardName, postId: postId)
            Log.repo.info("[PostRepositoryImpl.voteUpPost] Successfully voted up postId=\(postId)")
        } catch {
            Log.repo.error("[PostRepositoryImpl.voteUpPost] Failed for board=\(boardName) postId=\(postId) — \(error.localizedDescription)")
            throw error
        }
    }

    func uploadImage(data: Data, path: String) async throws -> String {
        Log.repo.info("[PostRepositoryImpl.uploadImage] Uploading image to path=\(path) size=\(data.count) bytes")
        do {
            let url = try await dataSource.uploadImage(data: data, path: path)
            Log.repo.info("[PostRepositoryImpl.uploadImage] Successfully uploaded image to path=\(path)")
            return url
        } catch {
            Log.repo.error("[PostRepositoryImpl.uploadImage] Failed for path=\(path) — \(error.localizedDescription)")
            throw error
        }
    }
}
