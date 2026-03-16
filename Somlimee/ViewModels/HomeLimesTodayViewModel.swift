//
//  HomeLimesTodayVM.swift
//  Somlimee
//
//  Created by Chanhee on 2024/03/13.
//

import Foundation

protocol HomeLimesTodayViewModel {
    var postList: LimeRoomPostList? { get }
    var isLoading: Bool { get }
    func loadPostList(boardName: String) async
}

@Observable
final class HomeLimesTodayViewModelImpl: HomeLimesTodayViewModel {
    var postList: LimeRoomPostList?
    var isLoading = false

    private let boardRepo: BoardRepository

    init(boardRepo: BoardRepository) {
        self.boardRepo = boardRepo
    }

    func loadPostList(boardName: String) async {
        Log.vm.debug("HomeLimesTodayViewModel.loadPostList: board=\(boardName)")
        isLoading = true
        defer { isLoading = false }
        guard let data = try? await boardRepo.getBoardPostMetaList(boardName: boardName, startTime: Date().description, counts: 10) else {
            Log.vm.error("HomeLimesTodayViewModel.loadPostList: failed to load posts")
            return
        }
        let list = data.map { LimeRoomPostMeta(userID: $0.userID, userName: $0.userName, title: $0.postTitle, views: $0.numberOfViews, publishedTime: $0.publishedTime, numOfVotes: $0.numberOfVoteUps, numOfComments: $0.numberOfComments, numOfViews: $0.numberOfViews, postID: $0.postID, boardPostTap: $0.boardTap, boardName: $0.boardID) }
        postList = LimeRoomPostList(list: list)
        Log.vm.debug("HomeLimesTodayViewModel.loadPostList: success — \(list.count) posts")
    }
}
