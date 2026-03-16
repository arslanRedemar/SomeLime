//
//  UCMemberWritePost.swift
//  Somlimee
//
//  Created by Chanhee on 2023/12/21.
//

import Foundation

protocol UCWritePost {
    func writePost(boardName: String, postContents: LimeRoomPostContent, postMeta: LimeRoomPostMeta) async -> Result<Void, Error>
}

class UCWritePostImpl: UCWritePost{
    private let postRepository: PostRepository

    init(postRepository: PostRepository){
        self.postRepository = postRepository
    }

    func writePost(boardName: String, postContents: LimeRoomPostContent, postMeta: LimeRoomPostMeta) async -> Result<Void, Error> {
        Log.useCase.info("UCWritePost.writePost: board=\(boardName) title=\(postMeta.title)")
        do {
            try await postRepository.writeBoardPost(boardName: boardName, postData: BoardPostContentData(boardPostTap: postMeta.boardPostTap, boardPostUserId: postMeta.userID, boardPostTitle: postMeta.title, boardPostParagraph: postContents.paragraph, boardPostImageURLs: postContents.imageURLs, boardPostComments: []))
            Log.useCase.info("UCWritePost.writePost: success")
            return .success(())
        } catch {
            Log.useCase.error("UCWritePost.writePost: failed — \(error)")
            return .failure(error)
        }
    }
}
