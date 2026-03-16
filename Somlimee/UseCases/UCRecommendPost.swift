//
//  UCRecommendPost.swift
//  Somlimee
//

import Foundation

protocol UCRecommendPost {
    func recommendPost(boardName: String, postId: String) async -> Result<Void, Error>
}

class UCRecommendPostImpl: UCRecommendPost {
    private let postRepository: PostRepository

    init(postRepository: PostRepository) {
        self.postRepository = postRepository
    }

    func recommendPost(boardName: String, postId: String) async -> Result<Void, Error> {
        Log.useCase.info("UCRecommendPost.recommendPost: board=\(boardName) postId=\(postId)")
        do {
            try await postRepository.voteUpPost(boardName: boardName, postId: postId)
            Log.useCase.info("UCRecommendPost.recommendPost: success")
            return .success(())
        } catch {
            Log.useCase.error("UCRecommendPost.recommendPost: failed — \(error)")
            return .failure(error)
        }
    }
}
