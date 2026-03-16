//
//  UCWriteComment.swift
//  Somlimee
//

import Foundation

protocol UCWriteComment {
    func writeComment(boardName: String, postId: String, target: String, text: String) async -> Result<Void, Error>
}

class UCWriteCommentImpl: UCWriteComment {
    private let postRepository: PostRepository

    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    func writeComment(boardName: String, postId: String, target: String, text: String) async -> Result<Void, Error> {
        Log.useCase.info("UCWriteComment.writeComment: board=\(boardName) postId=\(postId) target=\(target)")
        do {
            try await postRepository.writeComment(boardName: boardName, postId: postId, target: target, text: text)
            Log.useCase.info("UCWriteComment.writeComment: success")
            return .success(())
        } catch {
            Log.useCase.error("UCWriteComment.writeComment: failed — \(error)")
            return .failure(error)
        }
    }
}
