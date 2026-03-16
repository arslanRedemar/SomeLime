//
//  BoardPostViewModel.swift
//  Somlimee
//

import Foundation

protocol BoardPostViewModel {
    var meta: LimeRoomPostMeta? { get }
    var content: LimeRoomPostContent? { get }
    var comments: [LimeRoomPostComment] { get }
    var isLoading: Bool { get }
    var isSubmittingComment: Bool { get }
    var hasVoted: Bool { get }
    func loadPost(boardName: String, postId: String) async
    func loadComments(boardName: String, postId: String) async
    func submitComment(boardName: String, postId: String, text: String) async
    func voteUp(boardName: String, postId: String) async
}

@Observable
final class BoardPostViewModelImpl: BoardPostViewModel {
    var meta: LimeRoomPostMeta?
    var content: LimeRoomPostContent?
    var comments: [LimeRoomPostComment] = []
    var isLoading = false
    var isSubmittingComment = false
    var hasVoted = false

    private let getPost: UCGetPost
    private let getComments: UCGetComments
    private let writeComment: UCWriteComment
    private let recommendPost: UCRecommendPost

    init(getPost: UCGetPost, getComments: UCGetComments, writeComment: UCWriteComment, recommendPost: UCRecommendPost) {
        self.getPost = getPost
        self.getComments = getComments
        self.writeComment = writeComment
        self.recommendPost = recommendPost
    }

    func loadPost(boardName: String, postId: String) async {
        Log.vm.debug("BoardPostViewModel.loadPost: board=\(boardName) postId=\(postId)")
        isLoading = true
        defer { isLoading = false }

        async let metaResult = getPost.getPostMeta(boardName: boardName, postId: postId)
        async let contentResult = getPost.getPostContent(boardName: boardName, postId: postId)

        if case .success(let data) = await metaResult {
            meta = data
            Log.vm.debug("BoardPostViewModel.loadPost: meta loaded")
        }
        if case .success(let data) = await contentResult {
            content = data
            Log.vm.debug("BoardPostViewModel.loadPost: content loaded")
        }
    }

    func loadComments(boardName: String, postId: String) async {
        Log.vm.debug("BoardPostViewModel.loadComments: board=\(boardName) postId=\(postId)")
        let result = await getComments.getComments(boardName: boardName, postId: postId)
        if case .success(let data) = result {
            comments = data
            Log.vm.debug("BoardPostViewModel.loadComments: success — \(data.count) comments")
        }
    }

    func submitComment(boardName: String, postId: String, text: String) async {
        Log.vm.info("BoardPostViewModel.submitComment: board=\(boardName) postId=\(postId)")
        isSubmittingComment = true
        defer { isSubmittingComment = false }

        let result = await writeComment.writeComment(boardName: boardName, postId: postId, target: "", text: text)
        if case .success = result {
            Log.vm.info("BoardPostViewModel.submitComment: success")
            await loadComments(boardName: boardName, postId: postId)
        } else {
            Log.vm.error("BoardPostViewModel.submitComment: failed")
        }
    }

    func voteUp(boardName: String, postId: String) async {
        guard !hasVoted else { return }
        Log.vm.info("BoardPostViewModel.voteUp: board=\(boardName) postId=\(postId)")
        let result = await recommendPost.recommendPost(boardName: boardName, postId: postId)
        if case .success = result {
            hasVoted = true
            if meta != nil {
                meta?.numOfVotes += 1
            }
            Log.vm.info("BoardPostViewModel.voteUp: success")
        } else {
            Log.vm.error("BoardPostViewModel.voteUp: failed")
        }
    }
}
