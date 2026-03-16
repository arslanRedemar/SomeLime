//
//  UCGetLimeRoomMeta.swift
//  Somlimee
//
//  Created by Chanhee on 2024/02/13.
//

import Foundation

protocol UCGetLimeRoomMeta {
    func getLimeRoomMeta(boardName: String) async -> Result<LimeRoomMeta, Error>
}

class UCGetLimeRoomMetaImpl: UCGetLimeRoomMeta{
    private let boardRepository: BoardRepository

    init(boardRepository: BoardRepository){
        self.boardRepository = boardRepository
    }

    func getLimeRoomMeta(boardName: String) async -> Result<LimeRoomMeta, Error> {
        Log.useCase.debug("UCGetLimeRoomMeta.getLimeRoomMeta: boardName=\(boardName)")
        do{
            guard let data = try await boardRepository.getBoardInfoData(name: boardName) else {
                throw UCGetMyLimeRoomMetaFailures.EmptyLimeRoom
            }
            Log.useCase.debug("UCGetLimeRoomMeta.getLimeRoomMeta: success — board=\(boardName)")
            return .success(LimeRoomMeta(limeRoomName: data.boardName, limeRoomDescription: data.boardDescription, limeRoomTabs: data.tapList, limeRoomImageName: boardName))
        }catch {
            Log.useCase.error("UCGetLimeRoomMeta.getLimeRoomMeta: failed — \(error)")
            return .failure(error)
        }
    }
}
