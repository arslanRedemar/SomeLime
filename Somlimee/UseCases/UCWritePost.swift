//
//  UCMemberWritePost.swift
//  Somlimee
//
//  Created by Chanhee on 2023/12/21.
//

import Foundation

protocol UCMemberWritePost {
    func writePost(boardName: String, postContents: LimeRoomPostContent, postMeta: LimeRoomPostMeta) async -> Result<Void, Error>
}

class UCMemberWritePostImpl: UCMemberWritePost{
    
    
    var postRepository: PostRepository!
    init(){
        postRepository = AppDelegate.container.resolve(PostRepository.self)
    }
    
    func writePost(boardName: String, postContents: LimeRoomPostContent, postMeta: LimeRoomPostMeta) async -> Result<Void, Error> {
        do {
            try await postRepository.writeBoardPost(boardName: boardName, postData: BoardPostContentData(boardPostTap: postMeta.boardPostTap, boardPostUserId: postMeta.userID, boardPostTitle: postMeta.title, boardPostParagraph: postContents.paragraph, boardPostImages: postContents.images))
        } catch {
            return .failure(error)
        }
    }
}


