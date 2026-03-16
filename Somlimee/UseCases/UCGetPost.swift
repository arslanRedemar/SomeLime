//
//  UCGetPost.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/13.
//

import Foundation

protocol UCGetPost {
    func getPostMeta(boardName: String, postId: String) async -> Result<LimeRoomPostMeta, Error>
    func getPostContent(boardName: String, postId: String) async -> Result<LimeRoomPostContent, Error>
}

class UCGetPostImpl: UCGetPost{
    private let repository: PostRepository

    init(postRepository: PostRepository){
        self.repository = postRepository
    }

    func getPostMeta(boardName: String, postId: String) async -> Result<LimeRoomPostMeta, Error>{
        Log.useCase.debug("UCGetPost.getPostMeta: board=\(boardName) postId=\(postId)")
        do {
            guard let data = try await repository.getBoardPostMeta(boardName: boardName, postId: postId) else {
                throw UCGetPostFailures.EmptyData
            }
            Log.useCase.debug("UCGetPost.getPostMeta: success")
            return .success(LimeRoomPostMeta(userID: data.userID, userName: data.userName, title: data.postTitle, views: data.numberOfViews, publishedTime: data.publishedTime, numOfVotes: data.numberOfVoteUps, numOfComments: data.numberOfComments, numOfViews: data.numberOfViews, postID: data.postID, boardPostTap: data.boardTap, boardName: data.boardID))
        }catch{
            Log.useCase.error("UCGetPost.getPostMeta: failed — \(error)")
            return .failure(error)
        }
    }

    func getPostContent(boardName: String, postId: String) async -> Result<LimeRoomPostContent, Error>{
        Log.useCase.debug("UCGetPost.getPostContent: board=\(boardName) postId=\(postId)")
        do {
            guard let data = try await repository.getBoardPostContent(boardName: boardName, postId: postId) else {
                throw UCGetPostFailures.EmptyData
            }
            Log.useCase.debug("UCGetPost.getPostContent: success")
            return .success(LimeRoomPostContent(paragraph: data.boardPostParagraph, imageURLs: data.boardPostImageURLs, imgLocation: [], comments: []))
        }catch{
            Log.useCase.error("UCGetPost.getPostContent: failed — \(error)")
            return .failure(error)
        }
    }
}
