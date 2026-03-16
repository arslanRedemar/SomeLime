//
//  MyLimeRoomUC.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/12.
//

import Foundation

protocol UCGetMyLimeRoomMeta {
    func getMyLimeRoom() async -> Result<LimeRoomMeta, Error>
}

class UCGetMyLimeRoomMetaImpl: UCGetMyLimeRoomMeta{
    private let boardRepository: BoardRepository
    private let userRepository: UserRepository

    init(userRepository: UserRepository, boardRepository: BoardRepository){
        self.boardRepository = boardRepository
        self.userRepository = userRepository
    }

    func getMyLimeRoom() async -> Result<LimeRoomMeta, Error> {
        Log.useCase.debug("UCGetMyLimeRoomMeta.getMyLimeRoom: start")
        do{
            guard let name = try await userRepository.getUserData()?.personalityType else {
                throw UCGetMyLimeRoomMetaFailures.EmptyPersonalityType
            }
            guard let data = try await boardRepository.getBoardInfoData(name: name) else {
                throw UCGetMyLimeRoomMetaFailures.EmptyLimeRoom
            }
            Log.useCase.debug("UCGetMyLimeRoomMeta.getMyLimeRoom: success — type=\(name)")
            return .success(LimeRoomMeta(limeRoomName: data.boardName, limeRoomDescription: data.boardDescription, limeRoomTabs: data.tapList, limeRoomImageName: name))
        }catch {
            Log.useCase.error("UCGetMyLimeRoomMeta.getMyLimeRoom: failed — \(error)")
            return .failure(error)
        }
    }
}
