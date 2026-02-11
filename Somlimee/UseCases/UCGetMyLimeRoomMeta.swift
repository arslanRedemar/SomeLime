//
//  MyLimeRoomUC.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/12.
//

import Foundation
import UIKit

protocol UCMyLimeRoomMeta {
    func gerMyLimeRoom() async -> Result<LimeRoomMeta, Error>
    func getMyLimeRoomPostList() async -> Result<LimeRoomPostList, Error>
}

class UCMyLimeRoomMetaImpl: UCMyLimeRoomMeta{
    
    var boardRepository: BoardRepository!
    var userRepository: UserRepository!
    
    init(){
        boardRepository = AppDelegate.container.resolve(BoardRepository.self)
        userRepository = AppDelegate.container.resolve(UserRepository.self)
    }
    
    
    func gerMyLimeRoom() async -> Result<LimeRoomMeta, Error> {
        do{
            
            guard let name = try await userRepository.getUserData()?.personalityType else {
                throw UCMyLimeRoomMetaFailures.EmptyPersonalityType
            }
            guard let data = try await boardRepository.getBoardInfoData(name: name) else {
                throw UCMyLimeRoomMetaFailures.EmptyLimeRoom
            }
            return .success(LimeRoomMeta(limeRoomName: data.boardName, limeRoomDescription: data.boardDescription, limeRoomTabs: data.tapList, limeRoomImage: UIImage(named: name)!))
        }catch {
            return .failure(error)
        }
    }
    
    
    func getMyLimeRoomPostList() async -> Result<LimeRoomPostList, Error> {
        do{
            
            guard let userData = try await userRepository.getUserData() else {
                throw UCMyLimeRoomMetaFailures.EmptyUserData
            }
            guard let data = try await boardRepository.getBoardPostMetaList(boardName: userData.personalityType, startTime: Date(timeIntervalSinceNow: 0).description, counts: 5) else {
                throw UCMyLimeRoomMetaFailures.EmptyPostList
            }
            var list: [LimeRoomPostMeta] = []
            for meta in data {
                list.append(LimeRoomPostMeta(userID: meta.userID, userName: userData.userName, title: meta.postTitle, views: meta.numberOfViews, publishedTime: meta.publishedTime, numOfVotes: meta.numberOfVoteUps, numOfComments: meta.numberOfComments, postID: meta.postID, boardPostTap: meta.boardTap))
            }
            return .success(LimeRoomPostList(list: list))
        }catch {
            return .failure(error)
        }
       
    }
    
}
