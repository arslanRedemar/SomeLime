//
//  UCGetComments.swift
//  Somlimee
//

import Foundation

protocol UCGetComments {
    func getComments(boardName: String, postId: String) async -> Result<[LimeRoomPostComment], Error>
}

class UCGetCommentsImpl: UCGetComments {
    private let postRepository: PostRepository

    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    func getComments(boardName: String, postId: String) async -> Result<[LimeRoomPostComment], Error> {
        Log.useCase.debug("UCGetComments.getComments: board=\(boardName) postId=\(postId)")
        do {
            let data = try await postRepository.getComments(boardName: boardName, postId: postId)
            let comments = data.map { dto in
                LimeRoomPostComment(
                    userName: dto.userName,
                    userID: dto.userID,
                    postID: dto.postID,
                    target: dto.target,
                    publishedTime: dto.publishedTime,
                    isRevised: dto.isRevised == "Yes",
                    text: dto.text,
                    boardName: dto.boardName
                )
            }
            Log.useCase.debug("UCGetComments.getComments: success — \(comments.count) comments")
            return .success(comments)
        } catch {
            Log.useCase.error("UCGetComments.getComments: failed — \(error)")
            return .failure(error)
        }
    }
}
