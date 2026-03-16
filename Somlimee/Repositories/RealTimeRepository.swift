//
//  RealTimeRepository.swift
//  Somlimee
//
//  Created by Chanhee on 2024/01/25.
//

import Foundation

protocol RealTimeRepository {
    func getLimeTrendsData() async throws -> LimeTrendsData?
    func getBoardHotPostsList(boardName: String, startTime: String?, counts: Int) async throws -> [BoardPostMetaData]?
}

class RealTimeRepositoryImpl: RealTimeRepository {
    private let dataSource: DataSource

    init(dataSource: DataSource){
        self.dataSource = dataSource
    }

    func getBoardHotPostsList(boardName: String, startTime: String?, counts: Int) async throws -> [BoardPostMetaData]? {
        Log.repo.debug("[RealTimeRepositoryImpl.getBoardHotPostsList] Fetching hot posts for board=\(boardName) startTime=\(startTime ?? "nil") counts=\(counts)")
        do {
            guard let list = try await dataSource.getBoardHotPostsList(boardName: boardName, startTime: startTime, counts: counts) else {
                Log.repo.debug("[RealTimeRepositoryImpl.getBoardHotPostsList] No hot posts found for board=\(boardName)")
                return nil
            }
            var dataList: [[String: Any]] = []
            for id in list {
                guard var data = try await dataSource.getBoardPostMeta(boardName: boardName, postId: id) else {
                    continue
                }
                data["PostId"] = id
                dataList.append(data)
            }
            let result = try dataList.map { data in
                var meta = try DictionaryDecoder.decode(BoardPostMetaData.self, from: data)
                meta.boardID = boardName
                return meta
            }
            Log.repo.debug("[RealTimeRepositoryImpl.getBoardHotPostsList] Successfully fetched \(result.count) hot posts for board=\(boardName)")
            return result
        } catch {
            Log.repo.error("[RealTimeRepositoryImpl.getBoardHotPostsList] Failed for board=\(boardName) — \(error.localizedDescription)")
            throw error
        }
    }

    func getLimeTrendsData() async throws -> LimeTrendsData? {
        Log.repo.debug("[RealTimeRepositoryImpl.getLimeTrendsData] Fetching Lime trends data")
        do {
            guard let rawData = try await dataSource.getLimeTrendsData() else {
                Log.repo.debug("[RealTimeRepositoryImpl.getLimeTrendsData] No trends data found")
                return nil
            }
            let result = try DictionaryDecoder.decode(LimeTrendsData.self, from: rawData)
            Log.repo.debug("[RealTimeRepositoryImpl.getLimeTrendsData] Successfully fetched trends data")
            return result
        } catch {
            Log.repo.error("[RealTimeRepositoryImpl.getLimeTrendsData] Failed — \(error.localizedDescription)")
            throw error
        }
    }
}
