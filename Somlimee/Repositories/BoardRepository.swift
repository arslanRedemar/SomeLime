//
//  BoardRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/01/24.
//

import Foundation

protocol BoardRepository{
    func getBoardInfoData(name: String) async throws -> BoardInfoData?
    func getBoardPostMetaList(boardName: String, startTime: String?, counts: Int) async throws -> [BoardPostMetaData]?
}

class BoardRepositoryImpl: BoardRepository {
    private let dataSource: DataSource

    init(dataSource: DataSource){
        self.dataSource = dataSource
    }

    func getBoardInfoData(name: String) async throws -> BoardInfoData? {
        Log.repo.debug("[BoardRepositoryImpl.getBoardInfoData] Fetching board info for board=\(name)")
        do {
            guard let data = try await dataSource.getBoardInfoData(boardName: name) else {
                Log.repo.debug("[BoardRepositoryImpl.getBoardInfoData] No board info found for board=\(name)")
                return nil
            }
            var info = try DictionaryDecoder.decode(BoardInfoData.self, from: data)
            info.boardName = name
            Log.repo.debug("[BoardRepositoryImpl.getBoardInfoData] Successfully fetched board info for board=\(name)")
            return info
        } catch {
            Log.repo.error("[BoardRepositoryImpl.getBoardInfoData] Failed for board=\(name) — \(error.localizedDescription)")
            throw error
        }
    }

    func getBoardPostMetaList(boardName: String, startTime: String?, counts: Int) async throws -> [BoardPostMetaData]? {
        Log.repo.debug("[BoardRepositoryImpl.getBoardPostMetaList] Fetching post meta list for board=\(boardName) startTime=\(startTime ?? "nil") counts=\(counts)")
        do {
            guard let dataList = try await dataSource.getBoardPostMetaList(boardName: boardName, startTime: startTime, counts: counts) else {
                Log.repo.debug("[BoardRepositoryImpl.getBoardPostMetaList] No posts found for board=\(boardName)")
                return nil
            }
            let result = try dataList.map { data in
                var meta = try DictionaryDecoder.decode(BoardPostMetaData.self, from: data)
                meta.boardID = boardName
                return meta
            }
            Log.repo.debug("[BoardRepositoryImpl.getBoardPostMetaList] Successfully fetched \(result.count) posts for board=\(boardName)")
            return result
        } catch {
            Log.repo.error("[BoardRepositoryImpl.getBoardPostMetaList] Failed for board=\(boardName) — \(error.localizedDescription)")
            throw error
        }
    }
}
