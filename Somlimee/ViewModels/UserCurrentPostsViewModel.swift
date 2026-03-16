//
//  UserCurrentPostsViewModel.swift
//  Somlimee
//
//  Created by Chanhee on 2024/03/14.
//

import Foundation

protocol UserCurrentPostsViewModel {
    var posts: UserCurrentPosts? { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    func loadPosts() async
}

@Observable
final class UserCurrentPostsViewModelImpl: UserCurrentPostsViewModel {
    var posts: UserCurrentPosts?
    var isLoading = false
    var errorMessage: String?

    private let userRepo: UserRepository
    private let authRepo: AuthRepository

    init(userRepo: UserRepository, authRepo: AuthRepository) {
        self.userRepo = userRepo
        self.authRepo = authRepo
    }

    func loadPosts() async {
        Log.vm.debug("UserCurrentPostsViewModel.loadPosts: start")
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let userId = authRepo.currentUserID else {
            Log.vm.error("UserCurrentPostsViewModel.loadPosts: not logged in")
            errorMessage = "Not logged in"
            posts = UserCurrentPosts(list: [])
            return
        }

        do {
            let metaList = try await userRepo.getUserPosts(userId: userId)
            let postItems = metaList.map { meta in
                LimeRoomPostMeta(
                    userID: meta.userID,
                    userName: meta.userName,
                    title: meta.postTitle,
                    views: meta.numberOfViews,
                    publishedTime: meta.publishedTime,
                    numOfVotes: meta.numberOfVoteUps,
                    numOfComments: meta.numberOfComments,
                    numOfViews: meta.numberOfViews,
                    postID: meta.postID,
                    boardPostTap: meta.boardTap,
                    boardName: meta.boardID
                )
            }
            posts = UserCurrentPosts(list: postItems)
            Log.vm.debug("UserCurrentPostsViewModel.loadPosts: success — \(postItems.count) posts")
        } catch {
            Log.vm.error("UserCurrentPostsViewModel.loadPosts: failed — \(error)")
            errorMessage = error.localizedDescription
            posts = UserCurrentPosts(list: [])
        }
    }
}
