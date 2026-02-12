//
//  UCGetLimeRoomPostList.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/13.
//

import Foundation

protocol UCGetLimeRoomPostList {
    func getLimeRoomPostList(boardName: String, tabName: String, counts: Int) async -> Result<LimeRoomPostList, Error>
}

class UCGetLimeRoomPostListImpl: UCGetLimeRoomPostList{
    private let boardRepository: BoardRepository

    init(boardRepository: BoardRepository){
        self.boardRepository = boardRepository
    }

    func getLimeRoomPostList(boardName: String, tabName: String, counts: Int) async -> Result<LimeRoomPostList, Error> {
        do{
            guard let data = try await boardRepository.getBoardPostMetaList(boardName: boardName, startTime: "NaN", counts: counts) else {
                throw UCGetMyLimeRoomPostListFailures.EmptyPostList
            }
            var list: [LimeRoomPostMeta] = []
            for meta in data {
                list.append(LimeRoomPostMeta(userID: meta.userID, userName: meta.userName, title: meta.postTitle, views: meta.numberOfViews, publishedTime: meta.publishedTime, numOfVotes: meta.numberOfVoteUps, numOfComments: meta.numberOfComments, numOfViews: meta.numberOfViews, postID: meta.postID, boardPostTap: meta.boardTap, boardName: meta.boardID))
            }
            return .success(LimeRoomPostList(list: list))
        }catch {
            return .failure(error)
        }
    }
}
