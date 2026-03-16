//
//  UCGetMyLimeRoomPostList.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/13.
//

import Foundation

protocol UCGetMyLimeRoomPostList {
    func getMyLimeRoomPostList() async -> Result<LimeRoomPostList, Error>
}

class UCGetMyLimeRoomPostListImpl: UCGetMyLimeRoomPostList{
    private let boardRepository: BoardRepository
    private let userRepository: UserRepository

    init(boardRepository: BoardRepository, userRepository: UserRepository){
        self.boardRepository = boardRepository
        self.userRepository = userRepository
    }

    func getMyLimeRoomPostList() async -> Result<LimeRoomPostList, Error> {
        Log.useCase.debug("UCGetMyLimeRoomPostList.getMyLimeRoomPostList: start")
        do{
            guard let userData = try await userRepository.getUserData() else {
                throw UCGetMyLimeRoomPostListFailures.EmptyUserData
            }
            guard let data = try await boardRepository.getBoardPostMetaList(boardName: userData.personalityType, startTime: nil, counts: 5) else {
                throw UCGetMyLimeRoomPostListFailures.EmptyPostList
            }
            var list: [LimeRoomPostMeta] = []
            for meta in data {
                list.append(LimeRoomPostMeta(userID: meta.userID, userName: userData.userName, title: meta.postTitle, views: meta.numberOfViews, publishedTime: meta.publishedTime, numOfVotes: meta.numberOfVoteUps, numOfComments: meta.numberOfComments, numOfViews: meta.numberOfViews, postID: meta.postID, boardPostTap: meta.boardTap, boardName: meta.boardID))
            }
            Log.useCase.debug("UCGetMyLimeRoomPostList.getMyLimeRoomPostList: success — \(list.count) posts")
            return .success(LimeRoomPostList(list: list))
        }catch {
            Log.useCase.error("UCGetMyLimeRoomPostList.getMyLimeRoomPostList: failed — \(error)")
            return .failure(error)
        }
    }
}
