//
//  UserCurrentCommentsViewModel.swift
//  Somlimee
//
//  Created by Chanhee on 2024/03/14.
//

import Foundation

protocol UserCurrentCommentsViewModel {
    var comments: UserCurrentComments? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    func loadComments() async
}

@Observable
final class UserCurrentCommentsViewModelImpl: UserCurrentCommentsViewModel {
    var comments: UserCurrentComments?
    var isLoading = false
    var errorMessage: String?

    private let userRepo: UserRepository
    private let authRepo: AuthRepository

    init(userRepo: UserRepository, authRepo: AuthRepository) {
        self.userRepo = userRepo
        self.authRepo = authRepo
    }

    func loadComments() async {
        Log.vm.debug("UserCurrentCommentsViewModel.loadComments: start")
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let userId = authRepo.currentUserID else {
            Log.vm.error("UserCurrentCommentsViewModel.loadComments: not logged in")
            errorMessage = "Not logged in"
            comments = UserCurrentComments(list: [])
            return
        }

        do {
            let commentDataList = try await userRepo.getUserComments(userId: userId)
            let commentItems = commentDataList.map { data in
                LimeRoomPostComment(
                    userName: data.userName,
                    userID: data.userID,
                    postID: data.postID,
                    target: data.target,
                    publishedTime: data.publishedTime,
                    isRevised: data.isRevised == "Yes",
                    text: data.text,
                    boardName: data.boardName
                )
            }
            comments = UserCurrentComments(list: commentItems)
            Log.vm.debug("UserCurrentCommentsViewModel.loadComments: success — \(commentItems.count) comments")
        } catch {
            Log.vm.error("UserCurrentCommentsViewModel.loadComments: failed — \(error)")
            errorMessage = error.localizedDescription
            comments = UserCurrentComments(list: [])
        }
    }
}
